##### 2. Out of gas (Both)

**Issue:**

##### • The function _settlePrimaryMarkets() uses the loop to iterate

**through PrimaryMarkets. Function will be aborted with**
**OUT_OF_GAS exception if there will be a long**
**_primaryMarketMembers list.**

##### • The function settle() uses loops to iterate through

**obsoletePrimaryMarkets and newPrimaryMarkets. Function will be**
**aborted with OUT_OF_GAS exception if there will be a long**
**addresses lists.**

**Recommendation:**

**Check that the excluded array length is not too big.**

#### Owner privileges (In the period when the owner is not renounced)

         - **Owner can initialize contract.**

         - **Owner can add obsoletePrimaryMarkets and newPrimaryMarkets**
**addresses.**

         - **Owner can change dailyProtocolFeeRate.**

         - **Owner can change twapOracle, aprOracle, ballot and feeCollector**
**addresses.**

         - **Only PrimaryMarket addresses can burn and mint.**