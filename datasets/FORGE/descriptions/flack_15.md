#### L16 - Validate Variable Setters

**Criticality** Minor / Informative

**Location** Flack.sol#L425,453,457

**Status** Unresolved

#### Description

The contract performs operations on variables that have been configured on user-supplied

input. These variables are missing of proper check for the case where a value is zero. This

can lead to problems when the contract is executed, as certain actions may not be properly

handled when the value is zero.
```
 (bool success, ) =
 address(_token).call(abi.encodeWithSignature('transfer(address,uint256)',
 developerWallet, _amount))
 marketingWallet = _newWallet
 developerWallet = _newWallet

#### Recommendation

```
By adding the proper check, the contract will not allow the variables to be configured with

zero value. This will ensure that the contract can handle all possible input values and avoid

unexpected behavior or errors. Hence, it can help to prevent the contract from being

exploited or operating unexpectedly.


-----

