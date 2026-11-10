####  High Severity Issues

###### 1. Design issue

**Issue:**

###### • The _maxTxAmount and numTokensSellToAddToLiquidity values

**less than _tTotal(total supply). So that any there will be no adding**
**liquidity and _maxTxAmount checking has no meaning.**

**Recommendation:**

**Check the exceeded values and correct them to the real ones.**

