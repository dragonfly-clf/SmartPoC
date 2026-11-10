#### FAI - Function Argument Inconsistency

**Criticality** Minor / Informative

**Location** XMasGrok.sol#L355,368

**Status** Unresolved

#### Description

The business logic seems peculiar. The implementation may not follow the expected

behavior. The arguments on the `_getValue` function are called in the wrong order. As a

result, the tax fee is used as a liquidity fee and vice versa.
```
 function _getValues(uint256 tAmount) private view returns
 (uint256, uint256, uint256, uint256, uint256, uint256) {
 (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) =
 _getTValues(tAmount, _redisFee, _taxFee);
 ...
 }
 function _getTValues(uint256 tAmount, uint256 taxFee, uint256
 TeamFee) private pure returns (uint256, uint256, uint256) {

#### Recommendation

```
The team is advised to carefully check if the implementation follows the expected business

logic.


-----

