####  Low Severity Issues

##### 1. Out of gas

**Issue:**

##### • Functions massUpdatePools() uses the loop to update all loops from

**the poolInfo list. Function will be aborted with OUT_OF_GAS**
**exception if there will be a pool addresses list.**

**Recommendation:**

**Check that the poolInfo array length is not too big.**


-----

