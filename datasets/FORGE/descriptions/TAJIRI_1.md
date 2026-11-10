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

#### Owner privileges (In the period when the owner is not renounced)

         - **Owner can change the tax, _CherityFee and liquidity fee.**

         - **Owner can change the maximum transaction amount.**

         - **Owner can exclude from the fee.**

         - **Owner can lock and unlock. By the way, using these functions the**
**owner could retake privileges even after the ownership was**
**renounced.**