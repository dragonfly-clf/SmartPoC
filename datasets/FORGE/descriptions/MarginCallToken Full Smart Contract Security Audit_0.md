### High Severity Issues

###### 1. Wrong dead fee adding

Issue:

❏ Affected functions: _transferBothExcluded(), _transferStandard(),

_transferToExcluded(), _transferFromExcluded()
❏ deadFee amount taken from _tOwned[deadWallet] without any

checking in _isExcluded array
❏ deadFee amount taken from _rOwned[deadWallet] without multiplying

with currentRate

###### 2. Wrong airdrop amount distribution

Issue:

❏ Airdrop amount should be multiplied with currentRate, when subtract

from _rOwned[address(this)] and adding to _rOwned[msg.sender]
❏ Also need to check msg.sender if exist in _isExcluded array

Recommendation:

Multiply fee amount to currentRate. Check that addresses are not in
_isExcluded array.

