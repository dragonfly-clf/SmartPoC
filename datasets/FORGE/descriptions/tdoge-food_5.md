#### UL - Unused Liquidity

**Criticality** medium

**Location** contract.sol#L374

**Status** Unresolved

##### Description

The contract will never add liquidity because of the following condition:

 - _sellLPFee = 0 (this value never changes).

 - So lpAmount will always be zero.

|Criticality|medium|
|---|---|
|Location|contract.sol#L374|
|Status|Unresolved|


function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {

swapFee += swapFee;
uint256 lpFee = _sellLPFee;
uint256 lpAmount = tokenAmount * lpFee / swapFee;
…
if (lpAmount > 0) {

uint256 lpFist = fistBalance * lpFee / swapFee;
if (lpFist > 0) {

_swapRouter.addLiquidity(address(this), _fist, lpAmount, lpFist, 0, 0, fundAddress,
block.timestamp);

}
}
}


##### Recommendation

The team is advised to either initialize _sellLPFee to a higher value than 0 or add a
function that can set a new value to it.


-----

