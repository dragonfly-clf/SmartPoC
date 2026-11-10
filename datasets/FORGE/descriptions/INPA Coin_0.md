####  High Severity Issues

##### 1. Wrong allowance calculations

**Issue:**

         - **In transferFrom(address _from,…) function allowance decreases**
**with taxes included recalculated value, but should be decreased by**
**initial function argument value.**

**Recommendation:**

**Decrease allowance before taking from transfer amount or keep**
**transfer value in another variable to decrease allowance with**
**proper transfer amount.**

####  Medium Severity Issues

**No medium severity issues found.**

####  Low Severity Issues

**No low severity issues found.**

