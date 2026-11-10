Notable Information 📝

v Smart contract owner can burn tokens from contract.
```
 function burnFromStorage(uint256 amount) external onlyOwner {
  uint256 tokenAmount = amount * 10**decimals();
  super._transfer(address(this), address(0xdead), tokenAmount);

```
v Smart contract owner can whitelist wallets to bypass swap checks.
```
 function setIsWhitelisted(address account, bool value) external onlyOwner {
  isWhitelisted[account] = value;

```
v Smart contract owner can call `receive() for fallbacks. It is executed on a call to the contract`

with empty call data. Make sure the contract can receive token through a regular transaction,


### 📝

```
 receive() external payable {}

```

v Smart contract owner can change transaction fees. Maximum fee limits are set to allow the

value change within the set parameters.
```
 function setTaxes(uint256 newBuyTax, uint256 newSellTax, uint256 newTransferTax) external
onlyOwner {
  require(newBuyTax <= 500 && newSellTax <= 500 && newTransferTax <= 500, "Too high taxes");
  buyTax = newBuyTax;
  sellTax = newSellTax;
  transferTax = newTransferTax;

```
v Smart contract has an **informational severity issue which may or may not create any**

functional vulnerability.

“Functions that send ether to arbitrary addresses”

v Smart contract has a **low severity issue which may or may not create any functional**

vulnerability.

“Utilization of block.timestamp”

```
  uint256 tokenAmount = amount * 10**decimals();
super._transfer(address(this), address(0xdead), tokenAmount);

```
v Smart contract owner can whitelist wallets to bypass swap checks.
```
function setIsWhitelisted(address account, bool value) external onlyOwner {
  isWhitelisted[account] = value;

```
v Smart contract owner can call `receive() for fallbacks. It is executed on a call to the contract`

with empty call data. Make sure the contract can receive token through a regular transaction,

and does not throw an exception.
```
  receive() external payable {}

```
v Smart contract owner can change transaction fees. Maximum fee limits are set to allow the

value change within the set parameters.
```
function setTaxes(uint256 newBuyTax, uint256 newSellTax, uint256 newTransferTax) external
onlyOwner {
require(newBuyTax <= 500 && newSellTax <= 500 && newTransferTax <= 500, "Too high taxes");
  buyTax = newBuyTax;
  sellTax = newSellTax;
  transferTax = newTransferTax;

```
v Smart contract has an **informational severity issue which may or may not create any**

functional vulnerability.

“Functions that send ether to arbitrary addresses”


-----

v Smart contract has an **informational severity issue which may or may not create any**

functional vulnerability.

“Low level calls”

v Smart contract has an **informational severity issue which may or may not create any**

functional vulnerability.

“Public functions should be declared external”


functional vulnerability.

“Public functions should be declared external”


-----

## 