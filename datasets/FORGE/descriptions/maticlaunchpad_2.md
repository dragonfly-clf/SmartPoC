#### IF - Incomplete Functionality

**Criticality** minor

**Location** contract.sol#L845,876

##### Description

The contract contains a code segment with incomplete functionality. The function
accepts payment without tracking the senter’s deposit.

|Criticality|minor|
|---|---|
|Location|contract.sol#L845,876|

```
 function Participate() public payable returns (bool success){
  //address _refer
  //require(sSBlock <= block.number && block.number <= sEBlock);
  //require(sTot < sCap || sCap == 0);
  uint256 _eth = msg.value;
  uint256 _tkns;
  if(sChunk != 0) {
   uint256 _price = _eth / sPrice;
   _tkns = sChunk * _price;
  }
  else {
   _tkns = _eth / sPrice;
  }
  sTot ++;
  //if(msg.sender != _refer && balanceOf(_refer) != 0 && _refer !=
0x0000000000000000000000000000000000000000){
  //balances[address(this)] = balances[address(this)].sub(_tkns / 10);
  //balances[_refer] = balances[_refer].add(_tkns / 10);
  // emit Transfer(address(this), _refer, _tkns / 10);
  //}
  //balances[address(this)] = balances[address(this)].sub(_tkns);
  //balances[msg.sender] = balances[msg.sender].add(_tkns);
  //emit Transfer(address(this), msg.sender, _tkns);
  //emit Transfer(address(this), msg.sender, _tkns);
  return true;
  }
  function startSale(uint _sSUTCDateTime, uint _sEUTCDateTime, uint256
_sChunk, uint256 _sPrice, uint256 _sCap) public onlyOwner() {
  sSUTCDateTime = _sSUTCDateTime;
  sEUTCDateTime = _sEUTCDateTime;
  sChunk = _sChunk;
  sPrice =_sPrice;

```

-----

```
 sCap = _sCap;
 sTot = 0;
}

```

##### Recommendation

The contract could either remove the incomplete functionality or implement the
entire functionality of participation deposit.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|FSA|Fixed Swap Address|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L05|Unused State Variable|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L07|Missing Events Arithmetic|
|⬤|L15|Local Scope Variable Shadowing|
|⬤|L13|Divide before Multiply Operation|


-----

