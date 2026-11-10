Notable Information !

v Smart contract owner can authorize a wallet to modify “write contract” parameters. When

ownership is transferred, previous owner should not remain authorized.
```
  function transferOwnership(address payable adr) public onlyOwner {
    owner = adr;
    authorizations[adr] = true;

```
v Smart contract utilizes safemath function to avoid common smart contract vulnerabilities.
```
  string private _name = "Food-Fi";
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
v Smart contract owner can call `receive() for fallbacks. It is executed on a call to the contract`

with empty call data. Make sure the contract can receive token through a regular transaction,


## !

```
 receive() external payable {}

```

v Smart contract utilizes antibot function module to allow limited transactions after a number

of blocks from launch-block.
```
  function setAntiBot(address _antiBot, bool _enable) external authorized {
    pinkAntiBot = IPinkAntiBot(_antiBot);
    pinkAntiBot.setTokenOwner(msg.sender);

```
```
function transferOwnership(address payable adr) public onlyOwner {
    owner = adr;
    authorizations[adr] = true;

```
v Smart contract utilizes safemath function to avoid common smart contract vulnerabilities.
```
  string private _name = "Food-Fi";
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
v Smart contract owner can call `receive() for fallbacks. It is executed on a call to the contract`

with empty call data. Make sure the contract can receive token through a regular transaction,

and does not throw an exception.
```
  receive() external payable {}

```
v Smart contract utilizes antibot function module to allow limited transactions after a number

of blocks from launch-block.

```
    enableAntiBot = _enable;

```

-----

v Smart contract owner can change transaction fees. Maximum fee limits are set to allow the

value change within the set parameters.
```
  function setBuyFees(
    totalBuyFee = _liquidityFee.add(_reflectionFee).add(_marketingFee).add(_devFee);
    feeDenominator = _feeDenominator;
     require(totalBuyFee <= feeDenominator.mul(15).div(100), "Can't be greater than 15%");
  function setSellFees(
    totalSellFee = _liquidityFee.add(_reflectionFee).add(_marketingFee).add(_devFee);
    feeDenominator = _feeDenominator;
     require(totalSellFee <= feeDenominator.mul(15).div(100), "Can't be greater than 15%");

```
v Smart contract function `addLiquidity() should send auto liquidity to an inaccessible`

address.
```
      router.addLiquidityETH{value: amountBNBLiquidity}(
        address(this),
        amountToLiquify,
          0,
          0,
        autoLiquidityReceiver,
          block.timestamp

```
v Smart contract has an **informational severity issue which may or may not create any**

functional vulnerability.

“Irrelevant Code”

v Smart contract has a **low severity issue which may or may not create any functional**

vulnerability.

“Floating Pragma”

v Smart contract has a **low severity issue which may or may not create any functional**

vulnerability.

“Utilization of block.timestamp”

```
    feeDenominator = _feeDenominator;
  require(totalBuyFee <= feeDenominator.mul(15).div(100), "Can't be greater than 15%");
function setSellFees(
    totalSellFee = _liquidityFee.add(_reflectionFee).add(_marketingFee).add(_devFee);
    feeDenominator = _feeDenominator;
  require(totalSellFee <= feeDenominator.mul(15).div(100), "Can't be greater than 15%");

```
v Smart contract function `addLiquidity() should send auto liquidity to an inaccessible`

address.
```
      router.addLiquidityETH{value: amountBNBLiquidity}(
        address(this),
        amountToLiquify,
       0,
       0,
        autoLiquidityReceiver,
       block.timestamp

```
v Smart contract has an **informational severity issue which may or may not create any**

functional vulnerability.

“Irrelevant Code”

v Smart contract has a **low severity issue which may or may not create any functional**

vulnerability.

“Floating Pragma”

v Smart contract has a **low severity issue which may or may not create any functional**

vulnerability.

“Utilization of block.timestamp”


-----

# 