####  High Severity Issues

###### 1. Wrong supply burning

**Issue:**

###### • The function burnSupply() do not check sender to be excluded from

**reward consequently do not decrease _tOwned balance of sender if**
**it would be excluded.**

**Recommendation:**

**Check sender to be excluded from reward and decrease _tOwned**
**balance if needed.**

