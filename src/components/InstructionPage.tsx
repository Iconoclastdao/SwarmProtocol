import React from 'react';
import styled from 'styled-components';

const Container = styled.div`
  max-width: 800px;
  margin: 40px auto;
  padding: 20px;
  color: #fff;
  background-color: #121212;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  font-family: "Arial", sans-serif;
`;

const Title = styled.h1`
  font-size: 32px;
  margin-bottom: 20px;
  text-align: center;
  color: #4caf50;
`;

const Section = styled.section`
  margin-bottom: 30px;
`;

const SectionTitle = styled.h2`
  font-size: 24px;
  margin-bottom: 10px;
  color: #ff9800;
`;

const Paragraph = styled.p`
  font-size: 16px;
  line-height: 1.6;
`;

const InstructionList = styled.ul`
  list-style: disc;
  margin-left: 20px;
  font-size: 16px;
  line-height: 1.6;
`;

const InstructionPage: React.FC = () => {
  return (
    <Container>
      <Title>Swarm Protocol Instructions</Title>

      <Section>
        <SectionTitle>🔌 Connecting to the Swarm</SectionTitle>
        <Paragraph>
          Use MetaMask or any Web3 wallet to connect to the SwarmProtocol dashboard. Confirm you're on the correct chain to interact with oracle and executor contracts.
        </Paragraph>
      </Section>

      <Section>
        <SectionTitle>1️⃣ Submitting Data to SwarmOracle</SectionTitle>
        <InstructionList>
          <li>Go to the <strong>SwarmOracle Feed</strong> panel.</li>
          <li>Choose the asset pair (e.g., ETH/USD).</li>
          <li>Input your current price and submit as a provider.</li>
          <li>Only whitelisted providers (or staked users) may post data.</li>
        </InstructionList>
      </Section>

      <Section>
        <SectionTitle>2️⃣ Triggering Automations via SwarmExecutor</SectionTitle>
        <InstructionList>
          <li>Open the <strong>Executor Dashboard</strong>.</li>
          <li>Set target capsules, token pairs, or thresholds.</li>
          <li>Once price or condition is met, executor will call pre-approved functions.</li>
        </InstructionList>
      </Section>

      <Section>
        <SectionTitle>3️⃣ Managing Swarm Tokens</SectionTitle>
        <InstructionList>
          <li>Acquire <strong>IconoclastSwarmToken (IST)</strong> from the token faucet or liquidity pool.</li>
          <li>Stake tokens to gain voting power and register as a trusted provider.</li>
          <li>Use staked IST to vote on proposals or upgrade Swarm logic.</li>
        </InstructionList>
      </Section>

      <Section>
        <SectionTitle>4️⃣ DAO Governance (Coming Soon)</SectionTitle>
        <InstructionList>
          <li>IST holders will be able to vote on quorum thresholds, provider approvals, and Swarm updates.</li>
          <li>Staking-based slashing mechanisms may apply in the future to penalize malicious data.</li>
        </InstructionList>
      </Section>

      <Section>
        <SectionTitle>❓ Need Help?</SectionTitle>
        <InstructionList>
          <li>Ensure your wallet is connected and approved as a provider.</li>
          <li>Check that you have IST tokens staked to gain access to submissions.</li>
          <li>Join our Swarm support Discord or DAO forum for help.</li>
        </InstructionList>
      </Section>
    </Container>
  );
};

export default InstructionPage;
