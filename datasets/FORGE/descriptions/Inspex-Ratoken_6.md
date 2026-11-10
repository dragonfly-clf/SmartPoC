5.7. Improper Function Visibility

**ID** IDX-007

**Target** Token

**Category** Smart Contract Best Practice

**CWE** CWE-710: Improper Adherence to Coding Standards

**Risk** **Severity: Info**

**Impact: None**

**Likelihood: None**

**Status** **Resolved**
Ratoken team has resolved this issue as suggested and deployed the fixed version to
[0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195 on BSC mainnet.](https://bscscan.com/address/0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195)

Please note that the includeInReward(), setAllFeePercent(), setMaxTxPercent(),
and setMaxWalletPercent() functions have been removed.

#### 5.7.1. Description

Functions with public visibility copy calldata to memory when being executed, while external functions can
read directly from calldata. Memory allocation uses more resources (gas) than reading directly from calldata.

For example, the following source code shows that the transfer() function of the Token contract is set to
```
public and it is never called from any internal function.

```
**Token.sol**
```
 840 function transfer(address recipient, uint256 amount) public override returns
   (bool) {
 841 _transfer(_msgSender(), recipient, amount);
 842 return true;
 843 }

```
The following table contains all functions that have public visibility and are never called from any internal
function.

**File** **Contract** **Function** **Inherit From**

Token.sol (L:503) Token renounceOwnership() Ownable

Token.sol (L:512) Token transferOwnership() Ownable

Token.sol (L:523) Token lock() Ownable

( ) 23

|ID|IDX-007|
|---|---|
|Target|Token|
|Category|Smart Contract Best Practice|
|CWE|CWE-710: Improper Adherence to Coding Standards|
|Risk|Severity: Info Impact: None Likelihood: None|
|Status|Resolved Ratoken team has resolved this issue as suggested and deployed the fixed version to 0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195 on BSC mainnet. Please note that the includeInReward(), setAllFeePercent(), setMaxTxPercent(), and setMaxWalletPercent() functions have been removed.|

|840 841 842 843|function transfer(address recipient, uint256 amount) public override returns (bool) { _transfer(_msgSender(), recipient, amount); return true; }|
|---|---|

|File|Contract|Function|Inherit From|
|---|---|---|---|
|Token.sol (L:503)|Token|renounceOwnership()|Ownable|
|Token.sol (L:512)|Token|transferOwnership()|Ownable|
|Token.sol (L:523)|Token|lock()|Ownable|