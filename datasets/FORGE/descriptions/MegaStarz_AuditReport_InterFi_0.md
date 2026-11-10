Smart Contract – Manual Analysis

**Function** **Description** **Tested** **Verdict**

provides information about the total token

**Total Supply** Yes **Passed**

supply

provides account balance of the owner's

**Balance Of** Yes **Passed**

account

executes transfers of a specified number of

**Transfer** Yes **Passed**

tokens to a specified address

allow a spender to withdraw a set number of

**Approve** Yes **Passed**

tokens from a specified account

returns a set number of tokens from a spender to

**Allowance** Yes **Passed**

the owner

is an action in which the project buys back its

**Buy Back** tokens from the existing holders usually at a NA NA

market price

executes transfers of a specified number of

**Burn** NA NA

tokens to a burn address

executes creation of a specified number of

**Mint** NA NA

tokens and adds it to the total supply

circulating token supply adjusts (increases or

**Rebase** decreases) automatically according to a token's NA NA

price fluctuations

stops specified wallets from interacting with the

**Blacklist** NA NA

smart contract function modules

stops or locks all function modules of the smart

**Lock** Yes **! Low**

contract


**Total Supply** Yes **Passed**

supply

provides account balance of the owner's

**Balance Of** Yes **Passed**

account

executes transfers of a specified number of

**Transfer** Yes **Passed**

tokens to a specified address

allow a spender to withdraw a set number of

**Approve** Yes **Passed**

tokens from a specified account

returns a set number of tokens from a spender to

**Allowance** Yes **Passed**

the owner

is an action in which the project buys back its

**Buy Back** tokens from the existing holders usually at a NA NA

market price

executes transfers of a specified number of

NA NA

tokens to a burn address

executes creation of a specified number of

NA NA

tokens and adds it to the total supply

circulating token supply adjusts (increases or

**Rebase** decreases) automatically according to a token's NA NA

price fluctuations

stops specified wallets from interacting with the


-----

**Function** **Description** **Tested** **Verdict**

executes transfers of a specified dividend token

**Dividend** NA NA

to a specified address

executes transfers of a specified number of

**Airdrop** NA NA

tokens to a specified address

a non-whitelisted wallet can only transfer a

**Max Transaction** Yes **Passed**

specified number of tokens

a non-whitelisted wallet can only hold a

**Max Wallet** NA NA

specified number of tokens

stops some or all bot wallets from interacting

**Anti Bot** NA NA

with the smart contract

executes transfer of contract ownership to a

**Transfer Ownership** Yes **Passed**

specified wallet

**Renounce** executes transfer of contract ownership to a

Yes **Passed**

**Ownership** dead address


executes transfers of a specified number of

**Airdrop** NA NA

tokens to a specified address

a non-whitelisted wallet can only transfer a

**Max Transaction** Yes **Passed**

specified number of tokens

a non-whitelisted wallet can only hold a

**Max Wallet** NA NA

specified number of tokens

stops some or all bot wallets from interacting

**Anti Bot** NA NA

with the smart contract

executes transfer of contract ownership to a

**Transfer Ownership** Yes **Passed**

specified wallet

**Renounce** executes transfer of contract ownership to a

Yes **Passed**

**Ownership** dead address


-----

## Best Practices ✅

v Owner cannot stop or pause the smart contract.

v Owner cannot lock or burn the user assets.

v Owner cannot mint tokens after initial contract creation/deployment.

v The smart contract utilizes “SafeMath” function to avoid common smart contract


## ✅

```
  string private _name = "Megastarz";

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

## Warning 🛑

```
v Active smart contract owner: 0x891b813c9e4403394ab0b7bd5a3109fad1237aab

v **_Be aware that active smart contract owner privileges constitute an elevated impact to_**

**_smart contract’s safety and security._**

v Smart contract owner can lock or unlock the smart contract function modules.

v Smart contract owner can change **_max transaction %. There’s no threshold on max tx, the_**

smart contract owner can change the value to “zero”, and stop the users from buying or

selling the assets.


v Owner cannot mint tokens after initial contract creation/deployment.

v The smart contract utilizes “SafeMath” function to avoid common smart contract

vulnerabilities.
```
  string private _name = "Megastarz";
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

## Warning 🛑

```
v Active smart contract owner: 0x891b813c9e4403394ab0b7bd5a3109fad1237aab

v **_Be aware that active smart contract owner privileges constitute an elevated impact to_**

**_smart contract’s safety and security._**

v Smart contract owner can lock or unlock the smart contract function modules.


-----

v The smart contract has **_low severity issue which may or may not create any functional_**

vulnerability.

{


"resource": " /Megastarz.sol",

"owner": "_generated_diagnostic_collection_name_#0",

**"severity": 8, (! Low Severity)**

**"** **Expected pragma, import directive or contract/interface/library definition”,**

"source": "solc",

}


-----

# 