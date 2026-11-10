####  High Severity Issues

###### 1. Out of gas

**Issue:**

###### • The function _tokenTransfer() uses _transferStandard() function to

**send marketingAmt. _transferStandard operates only reflection**
**balance, but sender address is not checked to be excluded from**
**reward.**

**Recommendation:**

**Check the sender address to be excluded from reward and use**
**proper functions to send marketing amount.**

