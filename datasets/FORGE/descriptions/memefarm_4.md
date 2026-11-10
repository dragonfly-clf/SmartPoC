#### ZD - Zero Division

**Criticality** minor

**Location** contract.sol#L437

##### Description

The contract is using variables that may be set to zero as denominators. As a result,
the transactions will revert.

The following variables _totalDistributionShares and totalBNBFee can be set to zero
and provoke Zero Division. _totalDistributionShares and _liquidityShare can be set
to zero with the function setDistributionSettings.

|Criticality|minor|
|---|---|
|Location|contract.sol#L437|


function swapAndLiquify(uint256 tAmount) private lockTheSwap {

uint256 tokensForLP = tAmount.mul(_liquidityShare).div(_totalDistributionShares).div(2);
uint256 tokensForSwap = tAmount.sub(tokensForLP);

swapTokensForEth(tokensForSwap);
uint256 amountReceived = address(this).balance;

uint256 totalBNBFee = _totalDistributionShares.sub(_liquidityShare.div(2));

uint256 amountBNBLiquidity =
amountReceived.mul(_liquidityShare).div(totalBNBFee).div(2);

uint256 amountBNBTeam = amountReceived.mul(_teamShare).div(totalBNBFee);


##### Recommendation

The contract should prevent those variables to be set to zero or should not allow to
execute the corresponding statements.


-----

