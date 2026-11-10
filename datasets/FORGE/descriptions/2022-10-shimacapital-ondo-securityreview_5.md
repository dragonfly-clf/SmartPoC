6. Arbitrage opportunity in the PSM contract|Col2|
|---|---|
|Severity: Informational|Difcfiulty: High|
|Type: Timing|Finding ID: TOB-ONDO-6|
|Target: contracts/PSM.sol||


##### Description
Given two PSM contracts for two different stablecoins, users could take advantage of the
difference in price between the two stablecoins to engage in arbitrage.

This arbitrage opportunity exists because each PSM contract, regardless of the underlying
stablecoin, holds that 1 MONO is worth $1. Therefore, if 100 stablecoin tokens are
deposited into a PSM contract, the contract would mint 100 MONO tokens regardless of the
price of the collateral token backing MONO.

The PolyMinter contract is vulnerable to the same arbitrage opportunity.

##### Exploit Scenario
USDC is trading at $0.98, and USDT is trading at $1. A user deposits 10,000 USDC tokens
into the PSM contract and receives 10,000 MONO, which is worth $10,000, assuming there
are no minting fees. The user then burns the 10,000 MONO he received from depositing
the USDC, and he receives $9,990 worth of USDT in exchange, assuming there is a 0.1%
redemption fee. Therefore, the arbitrageur was able to make a risk-free profit of $190.

##### Recommendations
Short term, document all front-running and arbitrage opportunities throughout the
protocol, and ensure that users are aware of them. As development continues, reassess
the risks associated with these opportunities and the adverse effects they could have on
the protocol.

Long term, use an off-chain monitoring solution to detect any anomalous price fluctuations
for the supported collateral tokens. Additionally, develop an incident response plan to
ensure that any issues that arise can be addressed promptly and without confusion (see
appendix E).

Trail of Bits 32 Ondo Finance Security Assessment


-----

|