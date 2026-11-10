#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** minor

**Location** contract.sol#L702

##### Description

The contract owner has the authority to transfer funds without limit to the team
wallet. These funds have been accumulated from fees collected from the contract.
The owner may take advantage of it by calling the rescueFunds methods with
_token argument equal to zero address.

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

The contract could embody a check for the maximum amount of funds that can be
swapped. Since a huge amount may volatile the token’s price.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

