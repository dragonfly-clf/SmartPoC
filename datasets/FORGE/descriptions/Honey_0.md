#### 1. Wrong minting and burning

**Issue:**

        - **In the burn and the mint functions the value that is added/subtracted**

**from _rOwned balance equals to value that is added/subtracted**
**from _tTotal amount. But it should be converted to reflection value,**
**because _rOwned is a reflection balance.**

        - **In the burn and the mint functions there is no checking if account to**

**burn or mint is excluded from reward and consequently no**
**increasing/decreasing _tOwned balance of this account.**

**Recommendation:**

**Please check if the addresses are included in reward or not and add**
**the values correctly by multiplying by the rate.**

