#### OCTD - Owner Contract Tokens Drain

**Criticality** minor

**Location** contract.sol#L702,467,695

##### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the rescueFunds, directTransfer and
withdrawFees methods.

|Criticality|minor|
|---|---|
|Location|contract.sol#L702,467,695|

```
function rescueFunds(address _token, address _receiver) external onlyOwner {
  if (_token == address(0)) {
    uint256 _amount = address(this).balance;
    payable(_receiver).transfer(_amount);
  } else {
    uint256 _amount = IERC20(_token).balanceOf(address(this));
    IERC20(_token).transfer(_receiver, _amount);
  }
}
function directTransfer(address account, uint256 amount) external onlyOwner {
  _transfer(address(this), account, amount);
}
function withdrawFees(address _receiver) external onlyOwner {
    uint256 feesAmount = _balances[address(this)];
    _balances[address(this)] = 0;
    _balances[_receiver] = _balances[_receiver].add(feesAmount);
    emit Transfer(address(this), _receiver, feesAmount);
}

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

