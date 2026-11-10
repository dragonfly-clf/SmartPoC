####  Low Severity Issues

###### 2. Out of gas

**Issue:**

###### • The function excludeMultipleAccountsFromFees() uses the loop to

**exclude multiple accounts from fees. Function will be aborted with**
**OUT_OF_GAS exception if there will be a long addresses list.**

###### • The function excludeMultipleAccountsFromSnipe() uses the loop to

**exclude multiple accounts from snipe. Function will be aborted with**
**OUT_OF_GAS exception if there will be a long addresses list.**

**Recommendation:**

**Be careful about accounts array length.**

#### Notes: 

         - **Dividend tracker may be changed. So that logic of setBalance and**
**other functions could be another and not audited.**

         - **Staking bonus automatically removes only in transferring method.**

         - **When user reinvests tokens, automatic process is true but**
**allowAutoReinvest is false contract will not charge dividends.**

         - **If user not staking rewards will not charge.**