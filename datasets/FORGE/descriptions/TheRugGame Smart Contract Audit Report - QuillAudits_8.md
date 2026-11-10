2. Possibility of Miscalculation of Rewards

 Description

 If setsTrg() function is not called before the deposit() in the STRG starts, then it will lead to incorrect calculation of pendingRewards and dividendPerToken. By default the sTrg variable be a zero address.

 Remediation

 Consider making a call to setsTrg() for setting strg mandatory before any deposit activity in the STRG contract begins.

 Status

 Acknowledged


-----

###### Medium Severity Issues

 