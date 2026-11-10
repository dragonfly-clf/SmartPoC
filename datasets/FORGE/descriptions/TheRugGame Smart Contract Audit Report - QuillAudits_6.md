4. Naming convention

 Description

 The afterBalance variable holds the value of the token after the beforeBalance is subtracted from the current balance. This is the balance change, not afterBalance; it is slightly misleading and does not convey the intended message.

    uint256 afterBalance = IERC20(_token).balanceOf(address(this)) -       beforeBalance;
    uint256 amountToBurn = afterBalance / 2;     uint256 amountForHolders = afterBalance - amountToBurn;

 Remediation

 Consider renaming the variable afterBalance to balanceDifference.

 Status

 Resolved


-----

###### C. Contract - TRG.sol

 High Severity Issues

 