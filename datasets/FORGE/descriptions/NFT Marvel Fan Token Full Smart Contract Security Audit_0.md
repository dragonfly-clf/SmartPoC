#### 1. Wrong account including.

**Issue:**

###### • The function includeInReward() change current address with last in

**excluded array. But there is no index changing in**
**_excludedAddressToId of this last address that came to new place.**
**Because of this, in case of including that last address, idOfAccount**
**value will be wrong and function will change another address. So**
**that current supply will calculate with the wrong value.**

**Recommendation:**

**Set new index in _excludedAddressToId for changed address.**

####  Medium Severity Issues

**No medium severity issues found.**

####  Low Severity Issues

##