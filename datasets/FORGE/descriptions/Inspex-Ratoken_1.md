5.2. Improper Balance Calculation

**ID** IDX-002

**Target** Token

**Category** Advanced Smart Contract Vulnerability

**CWE** CWE-840: Business Logic Errors

**Risk** **Severity: Medium**

**Impact: Medium**
The balance of a previously excluded address can be inflated by using the
```
       includeInReward() function, which is unfair to the token holders.

```
**Likelihood: Medium**
The exclusion and inclusion of an address can only be done by the contract owner;
however, it is possible that the contract owner will perform this action since it is profitable.

**Status** **Resolved**
Ratoken team has resolved this issue by removing the includeInReward() function and
[deployed the fixed version to 0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195](https://bscscan.com/address/0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195) on BSC
mainnet.

#### 5.2.1. Description

The Token contract has a reward mechanism based on $RFI to distribute the fees to the balance of the
holders. The holders are separated into two groups, those who are included in the reward distribution and
those who are excluded. The balance between two groups are calculated separately.

**Token.sol**
```
 835 function balanceOf(address account) public view override returns (uint256) {
 836 if (_isExcluded[account]) return _tOwned[account];
 837 return tokenFromReflection(_rOwned[account]);
 838 }

```
The contract owner can execute the excludeFromReward() function to exclude an address from gaining the
fee reward.

**Token.sol**
```
 904 function excludeFromReward(address account) public onlyOwner() {
 905 require(!_isExcluded[account], "Account is already excluded from reward");
 906 if(_rOwned[account] > 0) {
 907 _tOwned[account] = tokenFromReflection(_rOwned[account]);
 908 }
 909 _isExcluded[account] = true;

```
( ) 11

|ID|IDX-002|
|---|---|
|Target|Token|
|Category|Advanced Smart Contract Vulnerability|
|CWE|CWE-840: Business Logic Errors|
|Risk|Severity: Medium Impact: Medium The balance of a previously excluded address can be inflated by using the includeInReward() function, which is unfair to the token holders. Likelihood: Medium The exclusion and inclusion of an address can only be done by the contract owner; however, it is possible that the contract owner will perform this action since it is profitable.|
|Status|Resolved Ratoken team has resolved this issue by removing the includeInReward() function and deployed the fixed version to 0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195 on BSC mainnet.|

|835 836 837 838|function balanceOf(address account) public view override returns (uint256) { if (_isExcluded[account]) return _tOwned[account]; return tokenFromReflection(_rOwned[account]); }|
|---|---|

|904 905 906 907 908 909|function excludeFromReward(address account) public onlyOwner() { require(!_isExcluded[account], "Account is already excluded from reward"); if(_rOwned[account] > 0) { _tOwned[account] = tokenFromReflection(_rOwned[account]); } _isExcluded[account] = true;|
|---|---|


-----

Public

________
```
 910 _excluded.push(account);
 911 }

```
When an address is excluded, its balances will be excluded from the supply used in the token balance
calculation.

**Token.sol**
```
 1015 function _getCurrentSupply() private view returns(uint256, uint256) {
 1016 uint256 rSupply = _rTotal;
 1017 uint256 tSupply = _tTotal;
 1018 for (uint256 i = 0; i < _excluded.length; i++) {
 1019 if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply)
 1020 return (_rTotal, _tTotal);
 1021 rSupply = rSupply.sub(_rOwned[_excluded[i]]);
 1022 tSupply = tSupply.sub(_tOwned[_excluded[i]]);
 1023 }
 1024 if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
 1025 return (rSupply, tSupply);
   }

```
The contract owner can also use the includeInReward() function to reinclude an address for it to gain the
reward.

**Token.sol**
```
 913 function includeInReward(address account) external onlyOwner() {
 914 require(_isExcluded[account], "Already excluded");
 915 for (uint256 i = 0; i < _excluded.length; i++) {
 916 if (_excluded[i] == account) {
 917 _excluded[i] = _excluded[_excluded.length - 1];
 918 _tOwned[account] = 0;
 919 _isExcluded[account] = false;
 920 _excluded.pop();
 921 break;
 922 }
 923 }
 924 }

```
However, when that address is included again, the _rOwned balance of that address is not recalculated from
the value of _tOwned, causing this address to gain the reward from the period when it is excluded.

( ) 12

|910 911|_excluded.push(account); }|
|---|---|

|1015 1016 1017 1018 1019 1020 1021 1022 1023 1024 1025|function _getCurrentSupply() private view returns(uint256, uint256) { uint256 rSupply = _rTotal; uint256 tSupply = _tTotal; for (uint256 i = 0; i < _excluded.length; i++) { if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal); rSupply = rSupply.sub(_rOwned[_excluded[i]]); tSupply = tSupply.sub(_tOwned[_excluded[i]]); } if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal); return (rSupply, tSupply); }|
|---|---|

|913 914 915 916 917 918 919 920 921 922 923 924|function includeInReward(address account) external onlyOwner() { require(_isExcluded[account], "Already excluded"); for (uint256 i = 0; i < _excluded.length; i++) { if (_excluded[i] == account) { _excluded[i] = _excluded[_excluded.length - 1]; _tOwned[account] = 0; _isExcluded[account] = false; _excluded.pop(); break; } } }|
|---|---|


-----

Public

________

#### 5.2.2. Remediation

Inspex suggest calculating the _rOwned balance of the address on the reinclusion of it to the reward using
the current rate, for example:

**Token.sol**
```
 913 function includeInReward(address account) external onlyOwner() {
 914 require(_isExcluded[account], "Already excluded");
 915 for (uint256 i = 0; i < _excluded.length; i++) {
 916 if (_excluded[i] == account) {
 917 _excluded[i] = _excluded[_excluded.length - 1];
 918 uint256 currentRate = _getRate();
 919 _rOwned[account] = _tOwned[account].mul(currentRate);
 920 _tOwned[account] = 0;
 921 _isExcluded[account] = false;
 922 _excluded.pop();
 923 break;
 924 }
 925 }
 926 }

```
( ) 13

|913 914 915 916 917 918 919 920 921 922 923 924 925 926|function includeInReward(address account) external onlyOwner() { require(_isExcluded[account], "Already excluded"); for (uint256 i = 0; i < _excluded.length; i++) { if (_excluded[i] == account) { _excluded[i] = _excluded[_excluded.length - 1]; uint256 currentRate = _getRate(); _rOwned[account] = _tOwned[account].mul(currentRate); _tOwned[account] = 0; _isExcluded[account] = false; _excluded.pop(); break; } } }|
|---|---|


-----

Public

________

### 