#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L536

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero or
by setting the tradingOpen to false

|Criticality|critical|
|---|---|
|Location|contract.sol#L536|

```
if(!authorizations[sender] && !authorizations[recipient]){
  require(tradingOpen,"Trading not open yet");
}
uint256 rAmount = amount.mul(rate);
if (!authorizations[sender] && recipient != address(this) && recipient !=
address(DEAD) && recipient != pair && recipient != marketingFeeReceiver &&
recipient != devFeeReceiver && recipient != autoLiquidityReceiver){
  uint256 heldTokens = balanceOf(recipient);
  require((heldTokens + rAmount) <= _maxWalletToken,"Total Holding is
currently limited, you can not buy that much.");}
if (sender == pair &&
  buyCooldownEnabled &&
  !isTimelockExempt[recipient]) {
  require(cooldownTimer[recipient] < block.timestamp,"buy Cooldown exists");
  cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
}

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The contract should also prevent the owner from disabling the tradingOpen variable.
Usually this variables toggles only once from false to true.


-----

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

