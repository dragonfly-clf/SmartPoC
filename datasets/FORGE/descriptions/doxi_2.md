#### CO - Code Optimization

**Criticality** minor / informative

**Location** contract.sol#L912

**Status** Unresolved

##### Description

There are code segments that could be optimized. A segment may be optimized so
that it becomes a smaller size, consumes less memory, executes more rapidly, or
performs fewer operations. The contract calculates the rLiquidity twice, once in
the _getRValues() and once in the _takeLiquidity() method.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L912|
|Status|Unresolved|

```
function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256
currentRate) private pure returns (uint256, uint256, uint256) {
  uint256 rAmount = tAmount * currentRate;
  uint256 rFee = tFee * currentRate;
  uint256 rLiquidity = tLiquidity * currentRate;
  uint256 rTransferAmount = (rAmount - rFee) - rLiquidity;
  return (rAmount, rTransferAmount, rFee);
}
...
function _takeLiquidity(uint256 tLiquidity) private {
  uint256 currentRate = _getRate();
  uint256 rLiquidity = tLiquidity * currentRate;
  _rOwned[address(this)] = _rOwned[address(this)] + rLiquidity;
  if(_isExcluded[address(this)]) { _tOwned[address(this)] =
_tOwned[address(this)] + tLiquidity; } //TODO: Verify Change
}

```

##### Recommendation

The contract could rewrite some code segments so the runtime will be more
performant.


-----

