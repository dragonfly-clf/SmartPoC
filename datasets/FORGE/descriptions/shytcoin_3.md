#### FSA - Fixed Swap Address

**Criticality** Minor / Informative

**Location** SHYTCOIN.sol#L500

**Status** Unresolved

#### Description

The swap address is assigned once and it can not be changed. It is a common practice in

decentralized exchanges to create new swap versions. A contract that cannot change the

swap address may not be able to catch up to the upgrade. As a result, the contract will not

be able to migrate to a new liquidity pool pair or decentralized exchange.

Furthermore, the contract does not apply taxes in pure token transfers. As a result, if the

token is listed in a different pair or decentralized exchange, it will not apply fees, creating an

arbitrage from the main pair.


-----

#### Recommendation

The team is advised to add the ability to add multiple the pair addresses in order to cover

potential liquidity pools. It would be better to support multiple pair addresses so the token

will be able to have the same behavior in all the decentralized liquidity pairs.


-----

