####  High Severity Issues

###### 1. Reward fee

**Issue:**

###### • Charity fee is subtracted from _rTotal value in _reflectFee() function.

**Also, exactly this fee amount goes to charity address.**

**Recommendation:**

**Please recheck logic of charity fee and keep only one way of taking**
**it – would it be reflecting or it would go to charity address.**
**Otherwise, reflection rate would be wrong.**

