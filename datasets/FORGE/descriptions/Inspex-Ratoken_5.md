5.6. Unchecked Return Value of ERC20 Transfer

**ID** IDX-006

**Target** Token

**Category** General Smart Contract Vulnerability

**CWE** CWE-710: Improper Adherence to Coding Standard

**Risk** **Severity: Info**

**Impact: None**

**Likelihood: None**

**Status** **Resolved**
Ratoken team has resolved this issue as suggested and deployed the fixed version to
[0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195 on BSC mainnet.](https://bscscan.com/address/0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195)

#### 5.6.1. Description

ERC20 tokens can be implemented in multiple ways, allowing the execution of failed transfer() and
```
transferFrom() functions by returning false instead of reverting when the invalid transfer amount occurs.

```
In the Token contract, the recoverBEP20() function can be used to transfer other tokens in the contract to
the contract owner.

**Token.sol**
```
 1328 function recoverBEP20(address tokenAddress, uint256 tokenAmount) public
   onlyOwner {
 1329 // do not allow recovering self token
 1330 require(tokenAddress != address(this), "Self withdraw");
 1331 IERC20(tokenAddress).transfer(owner(), tokenAmount);
 1332 }

```
The return value of the transfer() function is not checked, so the transfer transactions of tokens that return
```
false on failure will not be reverted.

```
However, there’s no impact in this case since this function is only used for the tokens mistakenly transferred
to the Token contract, and is not related to the users’ balances.

( ) 21

|ID|IDX-006|
|---|---|
|Target|Token|
|Category|General Smart Contract Vulnerability|
|CWE|CWE-710: Improper Adherence to Coding Standard|
|Risk|Severity: Info Impact: None Likelihood: None|
|Status|Resolved Ratoken team has resolved this issue as suggested and deployed the fixed version to 0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195 on BSC mainnet.|

|1328 1329 1330 1331 1332|function recoverBEP20(address tokenAddress, uint256 tokenAmount) public onlyOwner { // do not allow recovering self token require(tokenAddress != address(this), "Self withdraw"); IERC20(tokenAddress).transfer(owner(), tokenAmount); }|
|---|---|


-----

Public

________

#### 5.6.2. Remediation

Inspex suggests replacing the transfer() function with safeTransfer() function from OpenZeppelin's
```
SafeERC20 library, for example:

```
**Token.sol**
```
 1328 function recoverBEP20(address tokenAddress, uint256 tokenAmount) public
   onlyOwner {
 1329 // do not allow recovering self token
 1330 require(tokenAddress != address(this), "Self withdraw");
 1331 IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
 1332 }

```
( ) 22

|1328 1329 1330 1331 1332|function recoverBEP20(address tokenAddress, uint256 tokenAmount) public onlyOwner { // do not allow recovering self token require(tokenAddress != address(this), "Self withdraw"); IERC20(tokenAddress).safeTransfer(owner(), tokenAmount); }|
|---|---|


-----

Public

________

### 