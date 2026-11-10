#### MT - Mint Tokens

**Criticality** critical

**Location** contract.sol#L487

##### Description

The contract owner has the authority to mint up to 250.000.000 tokens. The owner
may take advantage of it by calling the mint function. The contract owner can mint
10% of the totalSupply yearly, with the limitation that totalSupply plus the amount
cannot be greater than the max supply (5 times the initial supply). As a result the
contract tokens will be highly inflated.

|Criticality|critical|
|---|---|
|Location|contract.sol#L487|

```
function mint(address _account, uint256 _amount) external onlyOwner {
  require(_totalSupply + _amount <= max_supply, "Mint limit reached");
  require(_account != address(0), "ERC20: mint to the zero address");
  uint16 curYear = DateTime.getYear(block.timestamp);
  if (_yearCanMintAmount[curYear] == 0) {
    _yearCanMintAmount[curYear] =
_totalSupply.mul(ANNUAL_MINTABLE_POINTS).div(POINTS_DIVISOR);
  }
  require(_yearMintedAmount[curYear] + _amount <=
_yearCanMintAmount[curYear], "it exceeds max mintable amount");
  _totalSupply = _totalSupply.add(_amount);
  _yearMintedAmount[curYear] = _yearMintedAmount[curYear].add(_amount);
  _balances[_account] = _balances[_account].add(_amount);
  emit Transfer(address(0), _account, _amount);
}

```

##### Recommendation

The owner should carefully manage the credentials of the owner’s account. We
advised considering an extra-strong security mechanism that the actions may be
quarantined by many users instead of one. The owner could also renounce the
contract ownership for a period of time or pass the access to the zero address.


-----

