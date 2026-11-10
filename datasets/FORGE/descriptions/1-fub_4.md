#### CR - Code Repetition

**Criticality** minor

**Location** contract.sol#L2214

###### Description

There are code segments that are repetitive in the contract. Those segments
increase the code size of the contract unnecessarily.

The swapManual method can be reused in the _tansfer method.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2214|


function swapManual() public onlyOwner {

uint256 contractTokenBalance = balanceOf(address(this));
require(contractTokenBalance > 0, "token balance zero");
swapping = true;
if(AmountLiquidityFee > 0) swapAndLiquify(AmountLiquidityFee);
if(AmountTokenRewardsFee > 0) swapAndSendDividends(AmountTokenRewardsFee);
if(AmountMarketingFee > 0) swapAndSendToFee(AmountMarketingFee);
swapping = false;
}


This code segment is repetitive in the contract.


LFee = amount.mul(buyLiquidityFee).div(100);
AmountLiquidityFee += LFee;
RFee = amount.mul(buyTokenRewardsFee).div(100);
AmountTokenRewardsFee += RFee;
MFee = amount.mul(buyMarketingFee).div(100);
AmountMarketingFee += MFee;
DFee = amount.mul(buyDeadFee).div(100);
fees = LFee.add(RFee).add(MFee).add(DFee);


###### Recommendation

Create an internal function that contains the code segment and remove it from all
the sections.


-----

