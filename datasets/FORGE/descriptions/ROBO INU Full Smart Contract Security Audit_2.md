####  Low Severity Issues

###### 2. Out of gas

**Issue:**

        - **The function _getCurrentSupply also uses the loop for evaluating**

**total supply. It also could be aborted with OUT_OF_GAS exception if**
**there will be a long excluded addresses list.**

**Recommendation:**

**Check that the excluded array length is not too big.**


-----

