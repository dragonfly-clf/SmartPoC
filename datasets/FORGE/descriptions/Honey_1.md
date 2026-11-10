##### 2. Reward fee 

**Issue:**

        - **Charity fee is subtracted from _rTotal value in _reflectFee function.**

**Also, exactly this fee amount goes to FeeAddress.**

**Recommendation:**

**Please recheck logic of charity fee and keep only one way of taking**
**it – would it be reflecting or it would go to the FeeAddress.**
**Otherwise, reflection rate would be wrong.**

####  Medium Severity Issues

**No medium severity issues found.**

####  Low Severity Issues

