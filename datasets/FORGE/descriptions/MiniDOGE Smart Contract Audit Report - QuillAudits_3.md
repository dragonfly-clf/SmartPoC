#### Informational

###### 8. Presence of unused code

 Line Code

 499 bool public _isEnabledBuyBackAndBurn = true;

 501 event RewardLiquidityProviders(uint256 tokenAmount);

 505-509 event SwapAndLiquify(
   uint256 tokensSwapped,   uint256 ethReceived,   uint256 tokensIntoLiqudity );

 850-863 function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
     // Approve token transfer to cover all possible scenarios     _approve(address(this), address(uniswapV2Router), tokenAmount);
     // Add the liquidity     uniswapV2Router.addLiquidityETH{value: ethAmount}(       address(this),       tokenAmount,       0, // Slippage is unavoidable       0, // Slippage is unavoidable       owner(),       block.timestamp   ); }

 Description The program contains code that is not essential for execution, i.e., makes no state changes and has no side effects that alter data or control flow, such that removal of the code would have no impact on functionality or correctness.

 0511