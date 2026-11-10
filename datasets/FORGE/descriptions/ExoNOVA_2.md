##### 2. Wrong distributeDividends

**Issue:**

##### • The function distributeDividends() has public access modifier. So

**that, everybody can call this function and distribute some BNBs. But**
**the project logic based on USDT distribution, and use same**
**magnifiedDividendPerShare and totalDividendsDistributed**
**variables for both BNB and USDTD distribution.**

**Recommendation:**

**Check and remove function if it’s not really needed.**

####  Medium Severity Issues

**No medium severity issues found.**

