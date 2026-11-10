##### 2. Unchecked random

**Issue:**

##### • In buyBackAndLiquifyEnabled block of transfer function,

**buyBackOrLiquidity random value is unused further. Instead of this**
**new random value for buyback fee is calculated.**

**Recommendation:**

**Do not forget to use checked value.**

