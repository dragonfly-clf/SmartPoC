19. Redundant Setting

 Line Code

 1291,1292, rewardCycleBlock = 7 days;
 easyRewardCycleBlock = 1 days;
 1295, 1300
 disruptiveCoverageFee = 2 ether; winningDoubleRewardPercentage = 5;

 0517


-----

###### Description Variables have been set to appropriate values in the declaration, so there is no need to set them again.

 Remediation We recommend removing redundant variable settings to save gas.

 Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit 984c12fa671fdd230a8ed69362249e4fe0a4a09a

 