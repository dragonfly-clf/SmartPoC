#### STC - Succeeded Transfer Check

**Criticality** minor

**Location** contract.sol#L513

##### Description

According to the ERC20 specification, the transfer methods should be checked if
the result is successful. Otherwise, the contract may wrongly assume that the
transfer has been established.

|Criticality|minor|
|---|---|
|Location|contract.sol#L513|


function claimStuckTokens(address token) external onlyOwner {

require(token != address(this), "Owner can not claim native tokens");
if (token == address(0x0)) {

payable(msg.sender).transfer(address(this).balance);
return;
}
IERC20 ERC20token = IERC20(token);
uint256 balance = ERC20token.balanceOf(address(this));
ERC20token.transfer(msg.sender, balance);
}


##### Recommendation

The contract should check if the result of the transfer methods is successful.


-----

