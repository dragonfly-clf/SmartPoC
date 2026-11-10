#### L02 - State Variables could be Declared Constant

**Criticality** Minor / Informative

**Location** contracts/Token.sol#L201,225,226

**Status** Unresolved

#### Description

State variables can be declared as constant using the constant keyword. This means that

the value of the state variable cannot be changed after it has been set. Additionally, the

constant variables decrease gas consumption of the corresponding transaction.
```
 address public MKT = 0xebb733EAB3C98975dEdd7341F0C1b5E7752F38D1
 uint256 public targetLiquidity = 20
 uint256 public targetLiquidityDenominator = 100

#### Recommendation

```
Constant state variables can be useful when the contract wants to ensure that the value of a

state variable cannot be changed by any function in the contract. This can be useful for

storing values that are important to the contract's behavior, such as the contract's address

or the maximum number of times a certain function can be called. The team is advised to

add the constant keyword to state variables that never change.


-----

