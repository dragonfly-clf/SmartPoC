## QSP-9 Amount in pools may be incorrect

#### Severity: Medium Risk

 Status: Fixed

###### File(s) affected: RariFundManager.sol (all repos)

 Description: The issue is visible in the rari-yield-pool-contracts repo, in the _withdrawFrom function in RariFundManager.sol:

#### 1. L666 computes: uint256 contractBalance = token.balanceOf(_rariFundControllerContract);

 2. L668-683 iterate over all pools in order to withdraw the remaining balance and add it to contractBalance

 3. L685 checks: require(amount <= contractBalance, "Available balance not enough to cover amount even after withdrawing from pools.");

 4. L686 recomputes the same value as on L666 into another variable: uint256 realContractBalance = token.balanceOf(_rariFundControllerContract);

 5. L709 checks if realContractBalance < amount ? realContractBalance : amount and transfers the resulting value.

###### This clearly shows that the following condition is possible: realContractBalance < amount <= contractBalance, which would indicate that the amounts withdrawn from the pools in
 the for-loop on L668-683 is discarded.


###### Recommendation: Clarify why following condition is possible: realContractBalance < amount <= contractBalance. Is this related to QSP-17? Fix the computation such that the
 values withdrawn from the pools is not discarded.


###### Update from dev team:


###### This is not related to QSP-17. We withdraw from pools until the sum of the requested pool withdrawal amounts is greater than or equal to the amount missing from the


###### contract balance that is necessary to cover amount. However, if a yVault pool charges a withdrawal fee, we want the user to pay this fee, so if the real contract balance after withdrawing from
 pools is less than the requested amount, we know a fee has been taken, and the user should pay it, so we only send them the real contract balance.

