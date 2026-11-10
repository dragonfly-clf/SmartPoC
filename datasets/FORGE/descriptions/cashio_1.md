#### Exceed Limit Fees Manipulation to Team Wallet

**Criticality** high

**Location** https://bscscan.com/address/0x54ef94beb6f890860f6bcee78b16b58613034771#c
ode#L727,L734

##### Description

The contract owner has the authority to arbitrarily increase the amount that is
accumulated to the team wallet. The owner may take advantage of it by calling the
```
setPrizePoolShare function with a high percentage value on _earningPlatform.

```
|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x54ef94beb6f890860f6bcee78b16b58613034771#c ode#L727,L734|

```
function setPrizePoolShare(uint256 _prizeShare, uint256 _nextRound, uint256
_distributionForPlayers, uint256 _earningPlatform) public onlyOwner {
  require(_prizeShare + _nextRound + _distributionForPlayers +
_earningPlatform == 100);
  sharePrizePoolForPrize = _prizeShare;
  sharePrizePoolForNextRound = _nextRound;
  sharePrizePoolAllPlayers = _distributionForPlayers;
  sharePrizePoolForEarningPlatform = _earningPlatform;
}

```

The same manipulation can happen on setTicketPriceShare setting a high value
on the _earningPlatform argument.

##### Recommendation

The contract could embody a check for the maximum acceptable value, for instance
10%.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

