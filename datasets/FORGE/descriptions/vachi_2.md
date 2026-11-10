#### L02 - State Variables could be Declared Constant

**Criticality** Minor / Informative

**Location** Novawchi.sol#L51,52,449,457,458,459,467,470,471,472

**Status** Unresolved

#### Description

State variables can be declared as constant using the constant keyword. This means that

the value of the state variable cannot be changed after it has been set. Additionally, the

constant variables decrease gas consumption of the corresponding transaction.
```
 address payable private _previousOwner
 uint256 private _lockTime
 address private burnAccount = 0x0000000000000000000000000000000000000001
 string private _name = "Novawchi"
 string private _symbol = "VACHI"
 uint8 private _decimals = 18
 uint256 public maxFee = 1000
 uint256 public rewardFee = 750
 uint256 public teamFee = 100
 uint256 public treasuryFee = 150

#### Recommendation

```
Constant state variables can be useful when the contract wants to ensure that the value of a

state variable cannot be changed by any function in the contract. This can be useful for

storing values that are important to the contract's behavior, such as the contract's address

or the maximum number of times a certain function can be called. The team is advised to

add the constant keyword to state variables that never change.


-----

