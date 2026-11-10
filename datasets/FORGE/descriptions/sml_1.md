#### OCTD - Transfers Contract's Tokens

**Criticality** medium

**Location** contract.sol#L950

**Status** Unresolved

##### Description

The _moonJPAddress initially holds 10% of total supply. If the awardFirstWinners
method is abused by the contract owner that one or many addresses may receive
10% of the total supply.

|Criticality|medium|
|---|---|
|Location|contract.sol#L950|
|Status|Unresolved|

```
function awardFirstWinners(address[] memory winningAddresses) external
onlyOwner() {
  _numberOfFirstPrizeWinner = winningAddresses.length ;
  uint256 _jpPortion = _rTotal.div(10**2).mul(10).mul(_jpRatio).div(10**3);
  uint256 eachPortion =
_rOwned[_moonWalletAddress].div(_numberOfFirstPrizeWinner);
  for (uint256 i = 0; i < winningAddresses.length; i++) {
    _rOwned[winningAddresses[i]] =
_rOwned[winningAddresses[i]].add(eachPortion);
    _rOwned[winningAddresses[i]] =
_rOwned[winningAddresses[i]].add(_jpPortion);
    _rOwned[_moonJPAddress] = _rOwned[_moonJPAddress].sub(_jpPortion);
  }
  _rOwned[_moonWalletAddress] =
_rOwned[_moonWalletAddress].sub(_rOwned[_moonWalletAddress]);
}

```

-----

##### Recommendation

The contract could embody a check for not allowing any address to be awarded
with more than a reasonable amount. A suggested implementation could check that
the maximum amount should be less than a fixed percentage of the total supply,
0.001% for example.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

