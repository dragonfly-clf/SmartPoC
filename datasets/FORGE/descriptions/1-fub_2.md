#### STC - Succeeded Transfer Check

**Criticality** minor

**Location** contract.sol#L2302

###### Description

According to the ERC20 specification, the transfer methods should be checked if
the result is successful. Otherwise, the contract may wrongly assume that the
transfer has been established.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2302|


function swapAndSendToFee(uint256 tokens) private {

uint256 initialCAKEBalance = IERC20(rewardToken).balanceOf(address(this));
swapTokensForCake(tokens);
uint256 newBalance =
(IERC20(rewardToken).balanceOf(address(this))).sub(initialCAKEBalance);

IERC20(rewardToken).transfer(_marketingWalletAddress, newBalance);
AmountMarketingFee = AmountMarketingFee - tokens;
}


###### Recommendation

The contract should check if the result of the transfer methods is successful.


-----

