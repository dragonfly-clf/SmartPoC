#### BLC - Business Logic Concern

**Criticality** minor / informative

**Location** contract.sol#L1768,1158

**Status** Unresolved

##### Description

The burn functionality emits a burn event from the contract address to the burn
address. According to the contract flow, the transfer is performed from the sender
to the burn address.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1768,1158|
|Status|Unresolved|


**function _burn(**

**uint256 amount,**
**uint256 fee,**
**uint256 index**
**) private {**

**uint256 tBurn = amount.mul(fee).div(FEES_DIVISOR);**

**_burnTokens(address(this), tBurn);**
//
**function _burnTokens(address sender, uint256 tBurn) internal {**

**_balances[burnAddress] = _balances[burnAddress].add(tBurn);**

**/****

*** @dev Emit the event so that the burn address balance is updated (on bscscan)**
***/**
**emit Transfer(sender, burnAddress, tBurn);**
**}**


-----

The ExternalToETH fee type is the same as the regular fee type. The ExternalToETH
fee type merely delegates the method to the regular fee type.


**if (name == FeeType.Burn) {**

**_burn(amount, value, index);**
**} else if (name == FeeType.ExternalToETH) {**

**_takeFeeToETH(amount, value, recipient, index);**
**} else {**

**_takeFee(amount, value, recipient, index);**
**}**
**//**
**function _takeFeeToETH(**

**uint256 amount,**
**uint256 fee,**
**address recipient,**
**uint256 index**
**) private {**

**_takeFee(amount, fee, recipient, index);**
**}**


##### Recommendation

The burn event should emit the sender’s address instead of the contract’s address.

The ExternalToETH case could be removed from the contract.


-----

