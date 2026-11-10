##### 3. Out of gas

**Issue:**

##### • The function excludeMultipleAccountsFromFees() uses the loop to

**exclude multiple accounts from fees. Function will be aborted with**
**OUT_OF_GAS exception if there will be a long addresses list.**

**Recommendation:**

**Be careful about accounts array length.**