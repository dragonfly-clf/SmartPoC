2. Arithmetic check

 Description

 pendingRewards() amount is an unsigned integer member of UserInfo struct and can never be less than zero.  
       if (user.amount <= 0) return 0; pendingRewards()
 The same goes for emergencyWithdraw() function.       if (user.amount <= 0) revert NotEnoughDeposit(); emergencyWithdraw()
 Also in the claimReward() function, userRewards is checked if its less than or equal to zero. But the following less than zero statement is not required as pendingRewards() returns an unsigned integer which can never be less than zero.        if (userReward <= 0) revert NotEnoughRewards(); claimReward()

 Remediation

 Consider removing the ‘<’ check as a best practice to avoid any misconceptions or logical errors.

 Status

 Resolved


-----

###### 