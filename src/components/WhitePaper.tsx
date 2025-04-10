import React from 'react';
import styled from 'styled-components';

const Container = styled.div`
  font-family: "Bradley DJR Variable", sans-serif;
  background-image: url('/logo1.jpeg');
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  background-attachment: fixed;
  color: white;
  text-shadow: 2px 2px 4px black;
  width: 100%;
  max-width: 900px;
  margin: 24px auto;
  padding: var(--padding);
  border-radius: var(--border-radius);
  box-shadow: var(--shadow);
`;

const Title = styled.h1`
  text-align: center;
  font-size: 2.2rem;
  margin-bottom: 2rem;
`;

const Section = styled.section`
  margin-bottom: 2rem;
`;

const SectionTitle = styled.h2`
  font-size: 1.6rem;
  margin-bottom: 1rem;
`;

const Paragraph = styled.p`
  font-size: 2rem;
  margin-bottom: 1rem;
  line-height: 1.5;
`;

const List = styled.ul`
  margin-left: 1.5rem;
  margin-bottom: 1rem;
  list-style: disc;

  li {
    margin-bottom: 0.5rem;
  }
`;

const WhitePaper: React.FC = () => (
  <Container>
    <Title>Swarm Protocol: Decentralized Data, Automation & Consensus Intelligence</Title>

    <Section>
      <SectionTitle>Abstract</SectionTitle>
      <Paragraph>
        The <strong>Swarm Protocol</strong> is a decentralized coordination layer for on-chain data, automation, and execution. It allows a distributed network of oracles to submit data, and enables automated responses via the Swarm Executor.
      </Paragraph>
      <Paragraph>
        Powered by the <strong>IconoclastSwarmToken</strong> (IST), the protocol enables staked providers, price feeds, governance voting, and automated triggers across any DApp or DeFi strategy.
      </Paragraph>
    </Section>

    <Section>
      <SectionTitle>1. Introduction</SectionTitle>
      <Paragraph>
        Today’s oracles are centralized, static, or siloed. Swarm offers a dynamic and modular framework that combines oracle validation, task automation, and protocol-level governance — all powered by token-weighted consensus.
      </Paragraph>
      <List>
        <li>Staked oracle network for reliable data submission.</li>
        <li>Real-time execution based on thresholds or strategy triggers.</li>
        <li>Cross-protocol automation for DeFi, agents, and DAOs.</li>
      </List>
    </Section>

    <Section>
      <SectionTitle>2. Core Contracts</SectionTitle>

      <SectionTitle>2.1 SwarmOracle</SectionTitle>
      <Paragraph>
        A modular oracle registry that accepts submitted data from approved providers. Includes price feed tracking and historical lookup. Can be expanded to non-financial data (weather, games, AI scores).
      </Paragraph>

      <SectionTitle>2.2 SwarmExecutor</SectionTitle>
      <Paragraph>
        A reactive automation contract. Monitors values in SwarmOracle and triggers pre-programmed functions like rebalances, trades, or reconfigurations.
      </Paragraph>

      <SectionTitle>2.3 SwarmProtocol</SectionTitle>
      <Paragraph>
        The core state manager. Governs consensus rules, provider registration, quorum thresholds, and interaction with off-chain interfaces.
      </Paragraph>

      <SectionTitle>2.4 IconoclastSwarmToken (IST)</SectionTitle>
      <Paragraph>
        A governance + staking token used to participate in Swarm decisions, reward providers, and lock in trust weight across modules.
      </Paragraph>
    </Section>

    <Section>
      <SectionTitle>3. Use Cases</SectionTitle>
      <List>
        <li>Decentralized price feeds across any token or pair.</li>
        <li>Real-time automation for trading, rebalancing, liquidation.</li>
        <li>AI strategy triggers or DAO proposals based on data conditions.</li>
        <li>Multi-agent mesh coordination for cross-capsule logic.</li>
      </List>
    </Section>

    <Section>
      <SectionTitle>4. Consensus & Validation</SectionTitle>
      <Paragraph>
        The SwarmOracle filters submitted data through provider reputation and token-weighted validation. Future upgrades will support zk proofs and slashing mechanisms.
      </Paragraph>
    </Section>

    <Section>
      <SectionTitle>5. Tokenomics</SectionTitle>
      <Paragraph>
        The <strong>IST Token</strong> governs Swarm. It is used to stake providers, pay execution gas subsidies, and vote on protocol upgrades. Inflationary yield may reward long-term stakers.
      </Paragraph>
    </Section>

    <Section>
      <SectionTitle>6. Roadmap</SectionTitle>
      <List>
        <li><strong>Phase 1:</strong> Oracle and Executor deployed on mainnet</li>
        <li><strong>Phase 2:</strong> Token staking, provider registry, and DAO integration</li>
        <li><strong>Phase 3:</strong> zk-proof oracle channels and AI agent hooks</li>
      </List>
    </Section>
  </Container>
);

export default WhitePaper;
