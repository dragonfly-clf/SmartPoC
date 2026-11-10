Notable Information 📝

v Smart contract owner can **mint tokens after initial contract creation/deployment. Mint**

without an upper limit and/or community consensus corresponds to elevated centralization

risk.
```
  function mint(address account, uint256 amount) onlyOwner public {
    totalSupply = totalSupply.add(amount);
    balances[account] = balances[account].add(amount);

```
v Smart contract owner can pause or unpause the smart contract function modules.
```
 function pause() onlyOwner whenNotPaused public {
  paused = true;
 function unpause() onlyOwner whenPaused public {
  paused = false;

```
v Smart contract utilizes safemath function to avoid common smart contract vulnerabilities.
```
  string private _name = "DogBoss";
  library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
     require(c >= a, "SafeMath: addition overflow");
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
     return sub(a, b, "SafeMath: subtraction overflow");
    uint256 c = a * b;
     require(c / a == b, "SafeMath: multiplication overflow");
     return c;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     return div(a, b, "SafeMath: division by zero");
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
     return mod(a, b, "SafeMath: modulo by zero");

```
v Smart contract owner can **blacklist certain wallets from interacting with the contract**

function modules.
```
 function _blackList(address _address, bool _isBlackListed) internal returns (bool) {
 require(tokenBlacklist[_address] != _isBlackListed);
 tokenBlacklist[_address] = _isBlackListed;

```

risk.
```
function mint(address account, uint256 amount) onlyOwner public {
    totalSupply = totalSupply.add(amount);
    balances[account] = balances[account].add(amount);

```
v Smart contract owner can pause or unpause the smart contract function modules.
```
function pause() onlyOwner whenNotPaused public {
  paused = true;
function unpause() onlyOwner whenPaused public {
  paused = false;

```
v Smart contract utilizes safemath function to avoid common smart contract vulnerabilities.
```
  string private _name = "DogBoss";
library SafeMath {
function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
  require(c >= a, "SafeMath: addition overflow");
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
  return sub(a, b, "SafeMath: subtraction overflow");
    uint256 c = a * b;
  require(c / a == b, "SafeMath: multiplication overflow");
  return c;
function div(uint256 a, uint256 b) internal pure returns (uint256) {
  return div(a, b, "SafeMath: division by zero");
function mod(uint256 a, uint256 b) internal pure returns (uint256) {
  return mod(a, b, "SafeMath: modulo by zero");

```
v Smart contract owner can **blacklist certain wallets from interacting with the contract**


### 📝


-----

v Smart contract owner can change transaction fees. This function module can be used to

impose extraordinary fees. No arbitrary limit set.
```
 function updateFee(uint256 _txFee,uint256 _burnFee,address _FeeAddress) onlyOwner public{
   txFee = _txFee;
   burnFee = _burnFee;

```
v Smart contract has an **informational severity issue which may or may not create any**

functional vulnerability.

**"severity": 4, (! Informational Severity)**

**“Irrelevant Code”**

v Smart contract has an **informational severity issue which may or may not create any**

functional vulnerability.

**"severity": 4, (! Informational Severity)**

**“Use of block.timestamp”**

```
   burnFee = _burnFee;

```
v Smart contract has an **informational severity issue which may or may not create any**

functional vulnerability.

**"severity": 4, (! Informational Severity)**

**“Irrelevant Code”**

v Smart contract has an **informational severity issue which may or may not create any**

functional vulnerability.

**"severity": 4, (! Informational Severity)**

**“Use of block.timestamp”**


-----

## 