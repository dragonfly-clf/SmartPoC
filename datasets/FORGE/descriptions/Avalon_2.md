##### 3. Wrong burning

**Issue:**

##### • The function _reflectFee() doesn’t check _BurnWallet to be excluded

**from reward and as a result doesn’t increase _tOwned[_BurnWallet]**
**value.**

**Recommendation:**

**Check burn address for be excluded and increase _ tOwned value if**
**true. Current burn wallet address is excluded from reward.**