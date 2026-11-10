#### L02 - State Variables could be Declared Constant

**Criticality** Minor / Informative

**Location** PEPESMOKING.sol#L680,684,685,686,696

**Status** Unresolved

#### Description

State variables can be declared as constant using the constant keyword. This means that

the value of the state variable cannot be changed after it has been set. Additionally, the

constant variables decrease gas consumption of the corresponding transaction.
```
 uint256 private _tTotal = 210000000000 * (10**18)
 string private _name = "$PEPESMOKING"
 string private _symbol = "PES"
 uint8 private _decimals = 18
 address public deadAddress =
 0x000000000000000000000000000000000000dEaD

#### Recommendation

```
Constant state variables can be useful when the contract wants to ensure that the value of a

state variable cannot be changed by any function in the contract. This can be useful for

storing values that are important to the contract's behavior, such as the contract's address

or the maximum number of times a certain function can be called. The team is advised to

add the constant keyword to state variables that never change.


-----

