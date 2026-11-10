###### 3. Wrong transfer

**Issue:**

###### • The function _tokenTransfer() uses _transferStandard to send burn

**and marketing amounts without any checking addresses to be**
**excluded from reward. If them would be, this is the high issue.**

**Recommendation:**

**Check addresses to be excluded from reward and use proper**
**functions to send amounts.**

