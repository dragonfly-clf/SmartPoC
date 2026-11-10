#### STC - Succeeded Transfer Check

**Criticality** minor

**Location** contract.sol#L702

##### Description

According to the ERC20 specification, the transfer methods should be checked if
the result is successful. Otherwise, the contract may wrongly assume that the
transfer has been established.

|Criticality|minor|
|---|---|
|Location|contract.sol#L702|

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

```

##### Recommendation

The contract should check if the result of the transfer methods is successful.


-----

