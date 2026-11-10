####  Low Severity Issues

##### 2. Out of gas

**Issue:**

##### • The function includeInReward() uses the loop to find and remove

**addresses from the _excluded list. Function will be aborted with**
**OUT_OF_GAS exception if there will be a long excluded addresses**
**list.**

        - **The function _getCurrentSupply also uses the loop for evaluating**

**total supply. It also could be aborted with OUT_OF_GAS exception if**
**there will be a long excluded addresses list.**

**Recommendation:**

**Check that the excluded array length is not too big.**

##### 3. Wrong reflection from token calculations

**Issue:**

         - **Missing parentheses when calculating target value.**
**tokenAmount**
**.sub(tokenAmount.mul(_taxFee).div(10**(_feeDecimal + 2)))**
**.mul(_getReflectionRate());**


-----

