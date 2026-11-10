##### 1. Wrong distributeBusdDividends

**Issue:**

##### • The function distributeUSDTDividends() has public access modifier.

**So that, everybody can call this function and ruin some part of the**
**contract logic.**

**Recommendation:**

**Change access modifier for this function to avoid whole access to**
**the function.**

