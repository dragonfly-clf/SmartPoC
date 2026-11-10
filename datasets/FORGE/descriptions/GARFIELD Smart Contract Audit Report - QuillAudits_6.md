5. Missing Check for Reentrancy Attack

 Description Calling GARFIELD.transfer() and GARFIELD.transferFrom() might trigger function pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferToke ns() and pancakeRouter.addLiquidityETH(), which is implemented by third party at pancakeRouter , in Utils.swapTokensForEth() and Utils.addLiquidity() . If there are vulnerable external calls in pancakeRouter , reentrancy attacks could be conducted because these two functions have state updates and event emits after external calls.

 The scope of the audit would treat the third-party implementation at pancakeRouter as a black box and assume its functional correctness. However, third parties may be compromised in the real world that leads to assets being lost or stolen.

 Remediation We recommend applying OpenZeppelin ReentrancyGuard library - nonReentrant modifier for the aforementioned functions to prevent reentrancy attacks.

 0508


-----

|Line|Code|
|---|---|
|1311 function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner() { _maxTxAmount = _tTotal.mul(maxTxPercent).div(10000); }||


###### Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit 5fd35320f0fbb22035ba61204afb857ec761c3f2

 