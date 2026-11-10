#### MAL - Misuse Algorithmic Logic

**Criticality** critical

**Location** contract.sol#L578

##### Description

The calculation on the denominator of the following line may produce precision
problems with the decimal point.

uint256 unitBalance= deltaBalance / (denominator - temp.liquidity);

The fees are not shared correctly across the wallets.

|Criticality|critical|
|---|---|
|Location|contract.sol#L578|


function swapAndLiquify(uint256 contractBalance, Taxes memory temp) private lockTheSwap{

uint256 denominator = (temp.liquidity + temp.marketing + temp.Stake + temp.Dapp) * 2;
uint256 tokensToAddLiquidityWith = contractBalance * temp.liquidity / denominator;
uint256 toSwap = contractBalance - tokensToAddLiquidityWith;
uint256 initialBalance = address(this).balance;
swapTokensForBNB(toSwap);
uint256 deltaBalance = address(this).balance - initialBalance;
uint256 unitBalance= deltaBalance / (denominator - temp.liquidity);
uint256 bnbToAddLiquidityWith = unitBalance * temp.liquidity;
if(bnbToAddLiquidityWith > 0){

// Add liquidity to pancake
addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
}
uint256 marketingAmt = unitBalance * 2 * temp.marketing;
if(marketingAmt > 0){

payable(marketingWallet).sendValue(marketingAmt);
}
uint256 StakeAmt = unitBalance * 2 * temp.Stake;
if(StakeAmt > 0){

payable(StakingPool).sendValue(StakeAmt);
}
uint256 DappAmt = unitBalance * 2 * temp.Dapp;
if(DappAmt > 0){

payable(DappRewardsPool).sendValue(DappAmt);
}
}


-----

##### Recommendation

The algorithm should be reshaped so it will match to the business logic. To avoid
problems with the decimal points the values should be multiplied with a factor.


-----

