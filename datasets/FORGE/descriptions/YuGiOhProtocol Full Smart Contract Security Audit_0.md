#### 1. Wrong burn fee taking

**Issue:**

###### • The function _sendToBurn () adds rBurn value to

**_tOwned[currentBurn], instead of adding tBurn value, which is not**
**multiplicated by current rate. This may cause wrong burn**
**calculations in future transfers.**

**Recommendation:**

**Use _takeBurn() function instead.**

####  Medium Severity Issues

**No medium severity issues found.**

####  Low Severity Issues

##