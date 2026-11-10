##### 1. Wrong distributeDividends

**Issue:**

##### • The function distributeDividends(uint256 amount) has public access

**modifier. So that, everybody can call this function with any amount**
**and ruin some part of the contract logic.**

**Recommendation:**

**Change access modifier for this function to avoid whole access to**
**the function.**

