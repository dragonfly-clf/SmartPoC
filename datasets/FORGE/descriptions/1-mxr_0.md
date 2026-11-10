#### ST - Stops Transactions

**Criticality** critical

**Location** contract.sol#L779

**Status** Unresolved

##### Description

The contract has the ability to set a max transaction cap on sales. The cap is
defined by the amount of tokens that is going to be transferred in comparison with
the user’s holdings. The table depicts the ranking amounts. Hence, the users will be
able to buy tokens but sale 5% or 1% of their holdings once per period. The period
is defined by the contract owner. As a result, the contract may operate similarly to a
honeypot.

|Criticality|critical|
|---|---|
|Location|contract.sol#L779|
|Status|Unresolved|

|honeypot.|Col2|Col3|Col4|
|---|---|---|---|
|Rank|Min amount|Max Amount|Cap|
|1|0|5000000|5%|
|2|5000001|totalSupply|1%|

```
require((currTradeVolume + amount) <= (balanceOf(from) * cap) / BASIS_POINTS,
"Epoch cap exceeded");

```

##### Recommendation

The contract should allow the users to trade a reasonable amount of tokens. An
acceptable percentage is 75% of their holdings.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|L01|Public Function could be Declared External|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|


-----

