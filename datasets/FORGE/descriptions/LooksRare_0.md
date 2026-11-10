6. Insufficient protection of sensitive information 29

7. Contracts used as dependencies do not track upstream changes 31

8. Missing event for a critical operation 32

9. Taker orders are not EIP-712 signatures 33

10. Solidity compiler optimizations can be problematic 35

Trail of Bits 3 LooksRare Security Assessment


-----

11. isContract may behave unexpectedly 36

12. tokenId and amount fully controlled by the order strategy when matching two
orders 37

13. Risk of phishing due to data stored in maker order params field 40

14. Use of legacy openssl version in solidity-coverage plugin 43

15. TypeScript compiler errors during deployment 44

Summary of Recommendations 45

A. Vulnerability Categories 46

B. Code Maturity Categories 48

C. Off-Chain Orderbook Assumptions and Recommendations 50

D. Risks Associated with Strategies 53

E. Roles and Privileges 55

F. System Invariants 56

G. Incident Response Recommendations 58

H. Code Quality Recommendations 60

I. Token Integration Checklist 61

Trail of Bits 4 LooksRare Security Assessment


-----

## Executive Summary

### Engagement Overview

LooksRare engaged Trail of Bits to review the security of its exchange and token staking
contracts. From February 28 to March 11, 2022, a team of two consultants conducted a
security review of the client-provided source code, with four person-weeks of effort. Details
of the project’s timeline, test targets, and coverage are provided in subsequent sections of
this report.

### Project Scope

Our testing efforts were focused on the identification of flaws that could result in the
compromise of a smart contract, a loss of funds, or unexpected behavior. We conducted
this audit with full knowledge of the target system, including access to the source code and
limited documentation. We performed static analysis and a manual review of the project’s
Solidity components.

### Summary of Findings

The audit did not uncover significant flaws that could result in the compromise of a smart
contract, a loss of funds, or unexpected behavior. A summary of the findings and details on
notable findings are provided below.


#### EXPOSURE ANALYSIS


#### CATEGORY BREAKDOWN


Trail of Bits 5 LooksRare Security Assessment


-----

### Notable Findings

Flaws that could impact the state of funds held in a contract or cause unexpected behavior
are listed below.

#### ●  Risk of reuse of signatures across forks ( TOB-LR-1 )

Due to the static generation of the DOMAIN_SEPARATOR in the contract constructor,
the system may be vulnerable to signature replay attacks on forked chains. This is
an issue inherent in EIP-712 implementations.

#### ●  Risks associated with contract ownership transfer process ( TOB-LR-2 )

Contract ownership is transferred in a single step, which is risky. Implementing a
two-step process for transferring contract ownership would allow ownership
transfers to be reversed if an incorrect address is input. This is an issue inherent in
OpenZeppelin contracts.

Trail of Bits 6 LooksRare Security Assessment


-----

## Project Summary

### Contact Information

The following managers were associated with this project:

**Dan Guido, Account Manager** **Mary O’Brien, Project Manager**
[dan@trailofbits.com](mailto:dan@trailofbits.com) mary.obrien@trailofbits.com

The following engineers were associated with this project:

**Nat Chin, Consultant** **Jaime Iglesias, Consultant**
natalie.chin@trailofbits.com jaime.iglesias@trailofbits.com

**Anish Naik, Consultant** **Robert Schneider, Consultant**
anish.naik@trailofbits.com robert.schneider@trailofbits.com

### Project Timeline

The significant events and milestones of the project are listed below.

**Date** **Event**

**February 24, 2022** Pre-project kickoff call

**March 7, 2022** Status update meeting #1

**March 11, 2022** Report readout meeting

**March 11, 2022** Delivery of report draft

**March 29, 2022** Delivery of final report

Trail of Bits 7 LooksRare Security Assessment


-----

## Project Goals

The engagement was scoped to provide a security assessment of the LooksRare exchange
and token staking contracts. Specifically, we sought to answer the following non-exhaustive
list of questions:

   - Could an attacker steal funds from the system?

   - Are there appropriate access controls in place for user and admin operations?

   - Could an attacker trap the system?

   - Are there denial-of-service attack vectors?

   - Could users lose access to their funds?

   - Does the system validate and limit fee amounts?

   - Does the system validate data from external contracts?

Trail of Bits 8 LooksRare Security Assessment


-----

## Project Targets

The engagement involved a review and testing of the following target.

LooksRare Contracts

Repository [https://github.com/LooksRare/looksrare-contracts](https://github.com/LooksRare/looksrare-contracts)

Version `072d96bc32081ff7aa5971973b351ecb1720b3cd`

Type Solidity

Platform Ethereum

Trail of Bits 9 LooksRare Security Assessment


-----

## Project Coverage

This section provides an overview of the analysis coverage of the review, as determined by
our high-level engagement goals. Our approaches and their results include the following:

#### LooksRare Exchange

This non-upgradeable contract is the core smart contract of the LooksRare protocol. It
defines the logic for users to match maker and taker orders, allowing them to buy and sell
NFTs. It is supported by a series of modules, called manager contracts, which define the
supported currencies, types of orders (strategies), royalty fees used in the system, and
transfer functionality to support multiple NFT standards.

#### Manager Contracts ( CurrencyManager, ExecutionManager,
```
 RoyaltyFeeManager )

```
These contracts allow LooksRare admins to add features to and remove features from the
protocol without relying on upgradeable contracts. For example, the CurrencyManager
contract is used to add and remove support for different currencies, and the
```
 ExecutionManager contract is used to add and remove different execution strategies,

```
allowing the protocol to support multiple order types. We focused on reviewing the risks
related to the various state changes, and we evaluated owner privileges throughout these
contracts.

#### Execution Strategies

These standalone contracts define the way an order is executed. For example, a maker may
want to sell a specific NFT or any item in a collection at a given price. Each contract
implements a common interface with the main functions canExecuteTakerAsk and
```
 canExecuteTakerBid and determines whether a maker order can be executed. We

```
evaluated the level of privilege that these strategies have on trades and used Echidna to
test the Dutch auction strategy calculations.

#### Exchange Libraries

There are two libraries in the LooksRare ecosystem: OrderTypes.sol and
```
 SignatureChecker.sol . While reviewing the OrderTypes.sol library, we verified that

```
[the MakerOrder struct is hashed according to the EIP-712 specification. Additionally, we](https://eips.ethereum.org/EIPS/eip-712)
ensured that the MakerOrder and TakerOrder structs have the necessary parameters to
perform correct order matching. While reviewing SignatureChecker.sol, we checked
[that the system correctly verifies and recovers EIP-712 -signed MakerOrder s.](https://eips.ethereum.org/EIPS/eip-712)

#### Exchange—Royalty Fee Helper Contracts

These smart contracts are used to store and retrieve royalty payment information for NFT
collections. We focused on checking whether the owner has excessive privileges and
whether the royaltyFeeLimit threshold can be violated.

Trail of Bits 10 LooksRare Security Assessment


-----

#### Exchange—Transfer Manager Contracts

The transfer manager contracts enable the LooksRare exchange to flexibly manage the
transfers of ERC721, ERC1155, and non-compliant ERC721 tokens. We focused on reviewing
the contracts’ compliance with the ERC721 and ERC1155 standards and their resilience to
calling non-compliant ERC721 tokens.

#### Token Staking— TokenDistributor

This contract allows users to stake LOOKS tokens to earn compounded interest over a
series of reward periods. We focused on the reward and share calculations and ensured
that the contract is resilient against flash loan attacks.

#### Token Staking— FeeSharingSystem

This contract provides another entry point to interact with the TokenDistributor
contract and allows users to gain WETH rewards. We focused on verifying the correctness
of the reward and share calculations.

#### Token Staking— LooksRareToken

This is an ERC20 token with a supply cap that is set on construction. We focused on
identifying ways in which the code could encounter unexpected behavior due to its
returning of a boolean instead of reverting when minting LOOKS tokens.

### Coverage Limitations

Because of the time-boxed nature of testing work, it is common to encounter coverage
limitations. During this project, we were unable to perform comprehensive testing of the
following system elements, which may warrant further review:

**●** **Token staking: The token staking smart contracts allow users to stake LOOKS**

tokens, receive rewards (in LOOKS tokens and fees), participate in the LOOKS token
airdrop, engage in private sales for LOOKS tokens, and participate in token vesting.
During this audit, we were unable to review the following contracts:

**○** `FeeSharingSetter.sol`

**○** `OperatorControllerForRewards.sol`

**○** `StakingPoolForUniswapV2Tokens.sol`

**○** `TokenSplitter.sol`

**○** `TradingRewardsDistributor.sol`

**○** `VestingContractWithFeeSharing.sol`

**○** `PrivateSaleWithFeeSharing.sol`

         - `LooksRareAirdrop.sol`

Trail of Bits 11 LooksRare Security Assessment


-----

**●** **Off-chain orderbook: The off-chain orderbook stores maker order signatures. This**

component was considered out of scope for our review. Our assumptions
surrounding the off-chain orderbook are highlighted in appendix C .

Trail of Bits 12 LooksRare Security Assessment


-----

## Automated Testing Results

Trail of Bits has developed unique tools for testing smart contracts. In this assessment, we
[used Echidna, a smart contract fuzzer that can rapidly test security properties via malicious,](https://github.com/trailofbits/echidna)
coverage-guided test case generation, to check various system states.

Automated testing techniques augment our manual security review but do not replace it.
Each technique has limitations; for example, Echidna may not randomly generate an edge
case that violates a property.

We follow a consistent process to maximize the efficacy of testing security properties.
When using Echidna, we generate 10 million test cases per property.

Our automated testing and verification focused on the following system properties:
```
 StrategyDutchAuction.sol . We used Echidna to check that the result of the Dutch

```
auction price calculation falls between endPrice and startPrice . If this invariant does
not hold, the currentAuctionPrice is faulty and may lead to additional price
manipulation. To test this price variation, we also used Echidna to identify the maximum
deviation from the bounds provided. Additionally, since the currentAuctionPrice
calculation requires the multiplication of potentially large values, we also tested whether
that operation could lead to an integer overflow.

**ID** **Property** **Tool** **Result**

1 The calculated currentAuctionPrice is always inclusively Echidna **PASSED**
bound between endPrice and startPrice .

2 The numerator for currentAuctionPrice cannot overflow. Echidna **FAILED**

3 Calculation of the maximum deviation that Echidna **0**
```
     currentAuctionPrice takes if it exits the inclusive bounds of
     endPrice and startPrice

```
Trail of Bits 13 LooksRare Security Assessment

|ID|Property|Tool|Result|
|---|---|---|---|
|1|The calculated currentAuctionPrice is always inclusively bound between endPrice and startPrice .|Echidna|PASSED|
|2|The numerator for currentAuctionPrice cannot overflow.|Echidna|FAILED|
|3|Calculation of the maximum deviation that currentAuctionPrice takes if it exits the inclusive bounds of endPrice and startPrice|Echidna|0|


-----

## Codebase Maturity Evaluation

Trail of Bits uses a traffic-light protocol to provide each client with a clear understanding of
the areas in which its codebase is mature, immature, or underdeveloped. Deficiencies
identified here often stem from root causes within the software development life cycle that
should be addressed through standardization measures (e.g., the use of common libraries,
functions, or frameworks) or training and awareness programs.

**Category** **Summary** **Result**

**Arithmetic**
Solidity v0.8.0 arithmetic operations are used in the **Moderate**
system and are tested through unit tests. Most arithmetic
and parameter-tuning operations for the NFT exchange
contracts are documented. However, automated fuzz
testing has not been integrated. See appendix F for our
recommendations on system invariants that can be tested.

**Auditing**
Many critical state-changing operations emit events; **Moderate**
however, one event is missing ( TOB-LR-8 ). The LooksRare
team provided additional details on the off-chain
computations and the way they are performed. However,
the team did not provide an incident response plan. See
appendix G for our recommendations on documenting
and maintaining an incident response plan.

**Authentication /**

The level of access provided to privileged users is limited **Satisfactory**

**Access Controls**

and is controlled by multisignature (multisig) wallet(s)
( appendix E ). The principle of least privilege is mostly
followed ( TOB-LR-5 ), and users can enter and exit the
system at will. Users can also use nonces to cancel orders
on a smart contract. The process of transferring contract
ownership can be improved by implementing a two-step
process ( TOB-LR-2 ).

**Complexity**

The system has a large number of peripheral managers **Moderate**

**Management**

and helpers that increase its overall complexity. Most
functions have clear purposes, and the system has a
modular architecture. We did not identify instances of
excessive branching. We recommend implementing our
code quality recommendations ( appendix H ) to reduce the

Trail of Bits 14 LooksRare Security Assessment

|Category|Summary|Result|
|---|---|---|
|Arithmetic|Solidity v0.8.0 arithmetic operations are used in the system and are tested through unit tests. Most arithmetic and parameter-tuning operations for the NFT exchange contracts are documented. However, automated fuzz testing has not been integrated. See appendix F for our recommendations on system invariants that can be tested.|Moderate|
|Auditing|Many critical state-changing operations emit events; however, one event is missing ( TOB-LR-8 ). The LooksRare team provided additional details on the off-chain computations and the way they are performed. However, the team did not provide an incident response plan. See appendix G for our recommendations on documenting and maintaining an incident response plan.|Moderate|
|Authentication / Access Controls|The level of access provided to privileged users is limited and is controlled by multisignature (multisig) wallet(s) ( appendix E ). The principle of least privilege is mostly followed ( TOB-LR-5 ), and users can enter and exit the system at will. Users can also use nonces to cancel orders on a smart contract. The process of transferring contract ownership can be improved by implementing a two-step process ( TOB-LR-2 ).|Satisfactory|
|Complexity Management|The system has a large number of peripheral managers and helpers that increase its overall complexity. Most functions have clear purposes, and the system has a modular architecture. We did not identify instances of excessive branching. We recommend implementing our code quality recommendations ( appendix H ) to reduce the|Moderate|


-----

|Col1|system’s complexity.|Col3|
|---|---|---|
|Cryptography and Key Management|EIP-712 struct hashing and signature verification is performed correctly. Additionally, the use of the EIP-712 standard decreases the risk of phishing attacks against users. See the “ Summary of Recommendations ” section for additional recommendations to mitigate phishing risks. Hot wallet key management was not evaluated as part of this audit.|Satisfactory|
|Decentralization|Privileged users can specify the tokens, strategies, and transfer managers that will be used for system execution. Additionally, the off-chain system acts as a single point of failure. Compromise of the off-chain system can lead to denial-of-service conditions.|Weak|
|Documentation|We were provided with sufficient documentation to reason through the protocol’s various process flows and data structures. We recommend developing additional documentation regarding the off-chain computations and token staking contracts.|Satisfactory|
|Front-Running Resistance|The protocol’s smart contracts are not upgradeable; therefore, there is no risk of initialization front-running. However, because takers submit makers’ signatures to the blockchain, there is a risk that taker orders could be front-run.|Moderate|
|Low-Level Calls|The system uses low-level calls minimally with the necessary safeguards and interacts with external contracts primarily through allowlists. We recommend using try-catch statements carefully while performing conditional low-level calls ( appendix H ).|Satisfactory|
|Testing and Verification|The test suite has 97% branch coverage, and Slither is used for static analysis. The test suite would benefit from automated verification such as Echidna fuzzing tests and|Moderate|


Trail of Bits 15 LooksRare Security Assessment


-----

|Col1|formal verification to test system properties.|Col3|
|---|---|---|


Trail of Bits 16 LooksRare Security Assessment


-----

## Summary of Findings

The table below summarizes the findings of the review, including type and severity details.

**ID** **Title** **Type** **Severity**

1 Risk of reuse of signatures across forks due to lack Authentication **High**
of chainID validation

2 Lack of two-step process for contract ownership Data **High**
changes Validation

3 Project dependencies contain vulnerabilities Patching **Medium**

4 Users that create ask orders cannot modify Data **Low**
minPercentageToAsk Validation

5 Excessive privileges of RoyaltyFeeSetter and Access **Low**
RoyaltyFeeRegistry owners Controls

6 Insufficient protection of sensitive information Configuration **Low**

7 Contracts used as dependencies do not track Patching **Low**
upstream changes

8 Missing event for a critical operation Auditing and **Low**
Logging

9 Taker orders are not EIP-712 signatures Data **Informational**
Validation

10 Solidity compiler optimizations can be problematic Undefined **Informational**
Behavior

11 isContract may behave unexpectedly Undefined **Informational**
Behavior

Trail of Bits 17 LooksRare Security Assessment

|ID|Title|Type|Severity|
|---|---|---|---|
|1|Risk of reuse of signatures across forks due to lack of chainID validation|Authentication|High|
|2|Lack of two-step process for contract ownership changes|Data Validation|High|
|3|Project dependencies contain vulnerabilities|Patching|Medium|
|4|Users that create ask orders cannot modify minPercentageToAsk|Data Validation|Low|
|5|Excessive privileges of RoyaltyFeeSetter and RoyaltyFeeRegistry owners|Access Controls|Low|
|6|Insufficient protection of sensitive information|Configuration|Low|
|7|Contracts used as dependencies do not track upstream changes|Patching|Low|
|8|Missing event for a critical operation|Auditing and Logging|Low|
|9|Taker orders are not EIP-712 signatures|Data Validation|Informational|
|10|Solidity compiler optimizations can be problematic|Undefined Behavior|Informational|
|11|isContract may behave unexpectedly|Undefined Behavior|Informational|


-----

|12|tokenId and amount fully controlled by the order strategy when matching two orders|Data Validation|Informational|
|---|---|---|---|
|13|Risk of phishing due to data stored in maker order params field|Data Validation|Informational|
|14|Use of legacy openssl version in solidity-coverage plugin|Patching|Informational|
|15|TypeScript compiler errors during deployment|Patching|Informational|


Trail of Bits 18 LooksRare Security Assessment


-----

## Detailed Findings

#### 1. Risk of reuse of signatures across forks due to lack of chainID validation

Severity: High Difficulty: High

Type: Authentication Finding ID: TOB-LR-1

Target: contracts/LooksRareExchange.sol

#### Description
At construction, the LooksRareExchange contract computes the domain separator using
the network’s chainID, which is fixed at the time of deployment. In the event of a
post-deployment chain fork, the chainID cannot be updated, and the signatures may be
replayed across both versions of the chain.
```
 constructor (
   address _currencyManager,
   address _executionManager,
   address _royaltyFeeManager,
   address _WETH,
   address _protocolFeeRecipient
 ) {
   // Calculate the domain separator
   DOMAIN_SEPARATOR = keccak256 (
     abi.encode(
        0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f, //
 keccak256("EIP712Domain(string name,string version,uint256 chainId,address
 verifyingContract)")
        0xda9101ba92939daf4bb2e18cd5f942363b9297fbc3232c9dd964abb1fb70ed71, //
 keccak256("LooksRareExchange")
        0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6, //
 keccak256(bytes("1")) for versionId = 1
        block.chainid,
        address ( this )
     )
   );
   currencyManager = ICurrencyManager(_currencyManager);
   executionManager = IExecutionManager(_executionManager);
   royaltyFeeManager = IRoyaltyFeeManager(_royaltyFeeManager);
   WETH = _WETH;
   protocolFeeRecipient = _protocolFeeRecipient;

```
Trail of Bits 19 LooksRare Security Assessment

|