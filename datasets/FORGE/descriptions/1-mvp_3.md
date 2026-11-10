#### MC - Missing Check

**Criticality** minor

**Location** contract.sol#L573, 708

##### Description

The contract is processing variables that have not properly sanitized and checked
that they form the proper shape. These variables may produce vulnerability issues.

|Criticality|minor|
|---|---|
|Location|contract.sol#L573, 708|

```
function setDistributionSettings(uint256 newLiquidityShare, uint256
newMarketingShare, uint256 newTeamShare) external onlyOwner() {
    _liquidityShare = newLiquidityShare;
    _marketingShare = newMarketingShare;
    _teamShare = newTeamShare;
    _totalDistributionShares =
_liquidityShare.add(_marketingShare).add(_teamShare);
  }

```
```
uint256 tokensForLP =
tAmount.mul(_liquidityShare).div(_totalDistributionShares).div(2);
    uint256 tokensForSwap = tAmount.sub(tokensForLP);
    swapTokensForEth(tokensForSwap);
    uint256 amountReceived = address(this).balance;
    uint256 totalBNBFee =
_totalDistributionShares.sub(_liquidityShare.div(2));
    uint256 amountBNBLiquidity =
amountReceived.mul(_liquidityShare).div(totalBNBFee).div(2);

```

##### Recommendation

The contract should properly check the variables according to the required
specifications


-----

