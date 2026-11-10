#### CR - Code Repetition

**Criticality** minor

**Location** contract.sol#L132,L165

##### Description

There are code segments that are repetitive in the contract. Those segments
increase the code size of the contract unnecessarily.

This code segment on function transfer is almost identical to the function
transferFrom.

|Criticality|minor|
|---|---|
|Location|contract.sol#L132,L165|

```
  require(tokenBlacklist[msg.sender] == false);
  require(_to != address(0));
  require(_value <= balances[msg.sender]);
  balances[msg.sender] = balances[msg.sender].sub(_value);
  uint256 tempValue = _value;
  if(txFee > 0 && msg.sender != FeeAddress){
    uint256 DenverDeflaionaryDecay = tempValue.div(uint256(100 / txFee));
    balances[FeeAddress] =
balances[FeeAddress].add(DenverDeflaionaryDecay);
    emit Transfer(msg.sender, FeeAddress, DenverDeflaionaryDecay);
    _value = _value.sub(DenverDeflaionaryDecay);
  }
  if(burnFee > 0 && msg.sender != FeeAddress){
    uint256 Burnvalue = tempValue.div(uint256(100 / burnFee));
    totalSupply = totalSupply.sub(Burnvalue);
    emit Transfer(msg.sender, address(0), Burnvalue);
    _value = _value.sub(Burnvalue);
  }
  // SafeMath.sub will throw if there is not enough balance.
balances[_to] = balances[_to].add(_value);
  emit Transfer(msg.sender, _to, _value);
  return true;

```

##### Recommendation

Create an internal function that contains the code segment and remove it from all
the sections.


-----

