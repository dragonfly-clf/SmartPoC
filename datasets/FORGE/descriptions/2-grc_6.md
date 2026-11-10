#### L02 - State Variables could be Declared Constant

**Criticality** Minor / Informative

**Location** GlobalReserveCoin.sol#L363,377

**Status** Unresolved

#### Description

State variables can be declared as constant using the constant keyword. This means that

the value of the state variable cannot be changed after it has been set. Additionally, the

constant variables decrease gas consumption of the corresponding transaction.
```
 address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
 uint256 public dividendsPerShareAccuracyFactor = 10 ** 36

#### Recommendation

```
Constant state variables can be useful when the contract wants to ensure that the value of a

state variable cannot be changed by any function in the contract. This can be useful for

storing values that are important to the contract's behavior, such as the contract's address

or the maximum number of times a certain function can be called. The team is advised to

add the constant keyword to state variables that never change.


-----

