/ SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


/**
 * @title SwarmOracle
 * @notice A decentralized, modular oracle system with consensus-based price aggregation and historical data tracking.
 */
contract SwarmOracle is Ownable(msg.sender), ReentrancyGuard {
    using SafeMath for uint256; // Note: Solidity 0.8+ has built-in overflow checks

    struct DataProvider {
        bool isActive;
        uint256 reputation;
    }

    struct PriceData {
        uint256 price;
        uint256 timestamp;
    }

    // Registered data providers
    mapping(address => DataProvider) public providers;

    // Historical price data for each asset
    mapping(bytes32 => PriceData[]) public priceHistory;

    // Mapping from asset to data submitted by providers in the current round
    mapping(bytes32 => mapping(address => uint256)) public submittedPrices;

    // List of providers that have submitted data for an asset in the current round
    mapping(bytes32 => address[]) private submissionsForAsset;

    // Tracks whether a provider has already submitted for an asset in the current round
    mapping(bytes32 => mapping(address => bool)) private hasSubmitted;

    // Latest aggregated price for each asset
    mapping(bytes32 => uint256) public aggregatedPrices;

    // Minimum number of submissions required to trigger aggregation
    uint256 public consensusThreshold = 3;

    event DataSubmitted(address indexed provider, bytes32 indexed asset, uint256 price);
    event PriceAggregated(bytes32 indexed asset, uint256 aggregatedPrice);
    event ProviderUpdated(address indexed provider, bool isActive, uint256 reputation);

    modifier onlyActiveProvider() {
        require(providers[msg.sender].isActive, "Not an active provider");
        _;
    }

    /**
     * @notice Register a new data provider.
     * @param provider The address of the provider to register.
     */
    function registerProvider(address provider) external onlyOwner {
        providers[provider] = DataProvider({ isActive: true, reputation: 0 });
        emit ProviderUpdated(provider, true, 0);
    }

    /**
     * @notice Update the active status of a data provider.
     * @param provider The address of the provider.
     * @param isActive The new active status.
     */
    function updateProvider(address provider, bool isActive) external onlyOwner {
        providers[provider].isActive = isActive;
        emit ProviderUpdated(provider, isActive, providers[provider].reputation);
    }

    /**
     * @notice Submit price data for a specific asset.
     * @param asset The asset identifier.
     * @param price The price data.
     */
    function submitData(bytes32 asset, uint256 price) external nonReentrant onlyActiveProvider {
        // If provider has not yet submitted for this asset in the current round, record their submission.
        if (!hasSubmitted[asset][msg.sender]) {
            submissionsForAsset[asset].push(msg.sender);
            hasSubmitted[asset][msg.sender] = true;
        }
        submittedPrices[asset][msg.sender] = price;

        // Increase provider reputation for participation.
        providers[msg.sender].reputation += 1;
        emit DataSubmitted(msg.sender, asset, price);

        // Check if the consensus threshold has been reached and, if so, aggregate the price data.
        if (submissionsForAsset[asset].length >= consensusThreshold) {
            aggregatePrice(asset);
        }
    }

    /**
     * @notice Aggregates the submitted price data for an asset.
     * @dev This function is called once the consensus threshold is met.
     * @param asset The asset identifier.
     */
    function aggregatePrice(bytes32 asset) internal {
        uint256 totalPrice = 0;
        uint256 count = submissionsForAsset[asset].length;
        require(count > 0, "No submissions to aggregate");

        // Sum all submissions and reset submission tracking for the asset.
        for (uint256 i = 0; i < count; i++) {
            address providerAddr = submissionsForAsset[asset][i];
            uint256 providerPrice = submittedPrices[asset][providerAddr];
            totalPrice = totalPrice.add(providerPrice);

            // Reset for next round.
            submittedPrices[asset][providerAddr] = 0;
            hasSubmitted[asset][providerAddr] = false;
        }

        uint256 consensusPrice = totalPrice.div(count);
        aggregatedPrices[asset] = consensusPrice;

        // Record the aggregated price in the price history.
        priceHistory[asset].push(PriceData({
            price: consensusPrice,
            timestamp: block.timestamp
        }));

        emit PriceAggregated(asset, consensusPrice);

        // Clear submissions for this asset to start a new round.
        delete submissionsForAsset[asset];
    }

    /**
     * @notice Retrieve the latest aggregated price for an asset.
     * @param asset The asset identifier.
     * @return The latest aggregated price.
     */
    function getPrice(bytes32 asset) external view returns (uint256) {
        return aggregatedPrices[asset];
    }

    /**
     * @notice Retrieve historical price data for an asset.
     * @param asset The asset identifier.
     * @param limit The maximum number of records to retrieve.
     * @return An array of PriceData records.
     */
    function getHistoricalPrices(bytes32 asset, uint256 limit) external view returns (PriceData[] memory) {
        uint256 historyLength = priceHistory[asset].length;
        uint256 fetchLimit = limit > historyLength ? historyLength : limit;
        PriceData[] memory history = new PriceData[](fetchLimit);
        for (uint256 i = 0; i < fetchLimit; i++) {
            history[i] = priceHistory[asset][historyLength - 1 - i];
        }
        return history;
    }

    /**
     * @notice Retrieve the current number of submissions for an asset in the ongoing round.
     * @param asset The asset identifier.
     * @return The count of submissions.
     */
    function getSubmissionCount(bytes32 asset) external view returns (uint256) {
        return submissionsForAsset[asset].length;
    }
}

/**
 * @title SwarmExecutor
 * @notice A decentralized automation system that triggers rebalancing events based on leverage conditions.
 */
contract SwarmExecutor is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    address public leverageTokenContract;
    uint256 public rebalanceThreshold = 5; // 5% deviation allowed before triggering rebalancing
    mapping(address => bool) public approvedExecutors;

    event ExecutorApproved(address indexed executor, bool approved);
    event RebalanceTriggered(uint256 indexed capsuleId, uint256 leverageRatio);

    modifier onlyApprovedExecutor() {
        require(approvedExecutors[msg.sender], "Not an approved executor");
        _;
    }

    constructor(address _leverageTokenContract) Ownable(msg.sender) {
        leverageTokenContract = _leverageTokenContract;
    }

    function approveExecutor(address executor, bool approved) external onlyOwner {
        approvedExecutors[executor] = approved;
        emit ExecutorApproved(executor, approved);
    }

    function triggerRebalance(uint256 capsuleId, uint256 currentLeverageRatio) external onlyApprovedExecutor {
        require(currentLeverageRatio >= rebalanceThreshold, "Leverage ratio within safe limits");
        (bool success, ) = leverageTokenContract.call(abi.encodeWithSignature("rebalance(uint256)", capsuleId));
        require(success, "Rebalance execution failed");
        emit RebalanceTriggered(capsuleId, currentLeverageRatio);
    }
}



/**
 * @title SwarmProtocol
 * @notice A decentralized, modular oracle and execution system for DeFi integrations.
 */
contract SwarmProtocol is Ownable(msg.sender), ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct DataProvider {
        bool isActive;
        uint256 reputation;
    }

    mapping(address => DataProvider) public providers;
    mapping(bytes32 => uint256) public priceFeeds;

    event DataSubmitted(address indexed provider, bytes32 asset, uint256 price);
    event ProviderUpdated(address indexed provider, bool isActive, uint256 reputation);

    modifier onlyActiveProvider() {
        require(providers[msg.sender].isActive, "Not an active provider");
        _;
    }

    function registerProvider(address provider) external onlyOwner {
        providers[provider] = DataProvider(true, 0);
        emit ProviderUpdated(provider, true, 0);
    }

    function submitData(bytes32 asset, uint256 price) external onlyActiveProvider {
        priceFeeds[asset] = price;
        providers[msg.sender].reputation += 1;
        emit DataSubmitted(msg.sender, asset, price);
    }

    function getPrice(bytes32 asset) external view returns (uint256) {
        return priceFeeds[asset];
    }
}


contract IconoclastSwarmToken is ERC20, ERC20Permit, ERC20Votes, Ownable {
    constructor(address recipient, address initialOwner)
        ERC20("Iconoclast Swarm Token", "IST")
        ERC20Permit("Iconoclast Swarm Token")
        Ownable(initialOwner)
    {
        _mint(recipient, 1000000000 * 10 ** decimals());
    }

    function clock() public view override returns (uint48) {
        return uint48(block.timestamp);
    }

    // solhint-disable-next-line func-name-mixedcase
    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=timestamp";
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}
