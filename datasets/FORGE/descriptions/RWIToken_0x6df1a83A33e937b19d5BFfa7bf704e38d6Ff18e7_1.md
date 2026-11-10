Notable Information 📝

v Smart contract owner can mint tokens after initial contract creation/deployment.

v Community consensus/voting will be introduced to reduce the centralization risk related to

mint. Review here: https://rwitoken.com/mint/

v Smart contract owner can pause or lock the smart contract function modules.

v The smart contract utilizes **SafeMath function to avoid common smart contract**


### 📝

```
  string private _name = "RWIToken";

```
```
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
v Smart contract owner can approve token burn to reduce the circulating supply.

v Smart contract owner can **blacklist certain wallets from interacting with the contract**

function modules.

v Smart contract has a **low severity issue which may or may not create any functional**

vulnerability.

**"severity": 8, (! Low Severity)**

**"** **Expected token Semicolon got 'LParen'”**


mint. Review here: https://rwitoken.com/mint/

v Smart contract owner can pause or lock the smart contract function modules.

v The smart contract utilizes **SafeMath function to avoid common smart contract**

vulnerabilities.
```
  string private _name = "RWIToken";
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
v Smart contract owner can approve token burn to reduce the circulating supply.

v Smart contract owner can **blacklist certain wallets from interacting with the contract**

function modules.

v Smart contract has a **low severity issue which may or may not create any functional**

vulnerability.

**"severity": 8, (! Low Severity)**

**"** **Expected token Semicolon got 'LParen'”**


-----

## 