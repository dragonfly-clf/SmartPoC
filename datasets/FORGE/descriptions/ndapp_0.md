#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L511,518,522

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the TwentyFourhours to a
high value and the maxSellAmount to 1. As a result, some users will not be able to
sell more than 1% of their holdings and some others will not be able to sell
completely.

|Criticality|critical|
|---|---|
|Location|contract.sol#L511,518,522|

```
uint256 sellPercent = balanceOf(sender).mul(maxSellAmount).div(100); //Should
use variable
require(amount <= sellPercent, "ERR: Can't sell more than maxSellAmount
percent");
if(blkTime > tradeData[sender].lastTradeTime + TwentyFourhours) {
  tradeData[sender].lastTradeTime = blkTime;
  tradeData[sender].tradeAmount = amount;
}
else if( (blkTime < tradeData[sender].lastTradeTime + TwentyFourhours) && ((
blkTime > tradeData[sender].lastTradeTime)) ){
  require(tradeData[sender].tradeAmount + amount <= sellPercent, "ERR: Can't
sell more than maxSellAmount percent in TwentyFourhours");
  tradeData[sender].tradeAmount = tradeData[sender].tradeAmount + amount;
}

```

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the
```
initialDistributionFinished to false or the maxSellTransactionAmount to a

```
very low value.

```
require(initialDistributionFinished || excludedAccount, "Trading not started");
///
require(amount <= maxSellTransactionAmount, "Error amount");

```

-----

##### Recommendation

The contract should not allow manipulating name sensitive variables like
```
TwentyFourhours.

```
The contract could embody a check for not allowing setting the
```
maxSellTransactionAmount and maxSellAmount less than a reasonable amount.

```
Additionally, the initialDistributionFinished should not be able to be disabled
after the initial mount. A suggested implementation could check that the maximum
amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|MTS|Manipulate Total Supply|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L05|Unused State Variable|
|⬤|L07|Missing Events Arithmetic|
|⬤|L09|Dead Code Elimination|
|⬤|L13|Divide before Multiply Operation|


-----

