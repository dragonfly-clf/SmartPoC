#### 1. Wrong burning

**Issue:**

##### • The function _burn() reduces _tTotal and adds token amount to zero

**address. So, sum of users’ balances will not equal total supply. Also**
**it do not decrease _rTotal.**

**Recommendation:**

**Choose one type of burning, decreasing supply or sending tokens to**
**zero address. Or recalculate user amount properly.**

####  Medium Severity Issues

**No medium severity issues found.**

####  Low Severity Issues

