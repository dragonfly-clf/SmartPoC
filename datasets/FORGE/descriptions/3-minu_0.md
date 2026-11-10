#### BLC - Business Logic Concern

**Criticality** critical

**Location** contract.sol#L1193

##### Description

The contract shares a proportion of the taxed amount to every user. Then, the same
amount is used in order to receive taxes. Thus, the contract sends more than the
expected taxed amount to addresses without updating the total supply. As a result,
the address balance is diverse from the total supply.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1193|

```
if (amount_accounts != 0) {
  uint256 _sReward = rBurn.div(amount_accounts);
  uint256 _tReward = tLiquidity.div(amount_accounts);
  for (uint256 i = 0; i < _accounts.length; i ++) {
    address _temp = _accounts[i];
    if (_temp != sender && _temp != recipient) {
       _rOwned[_temp] = _rOwned[_temp].add(_sReward);
       _buyHistories[_temp].push(History(block.timestamp, _tReward,
"buy"));
    }
  }
}

```

The contract takes one fee amount twice.

```
_takeLiquidity(tLiquidity);
_reflectFee(rBurn, tLiquidity);

```

The contract contains inconsistency between the real taxed fees, the transferable
amount after the taxes and the actual amount since it multiplies the taxed amount
four times after the initial calculation.

```
function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {
  uint256 tFee = calculateFee(tAmount);
  uint256 tTransferAmount = tAmount.sub(tFee.mul(4));
  return (tTransferAmount, tFee);
}

```

-----

The contract is using a fee called “rBurn” in order to receive tazed in the marketing
address.

```
_rOwned[marketing_address] = _rOwned[marketing_address].add(rBurn);

```

##### Recommendation

The team is advised to carefully check if the implementation follows the expected
business logic.


-----

