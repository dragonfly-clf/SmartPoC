5.5. Insufficient Logging for Privileged Functions

**ID** IDX-005

**Target** Token

**Category** Advanced Smart Contract Vulnerability

**CWE** CWE-778: Insufficient Logging

**Risk** **Severity: Very Low**

**Impact: Low**
Privileged functions' executions cannot be monitored easily by the users.

**Likelihood: Low**
It is not likely that the execution of the privileged functions will be a malicious action.

**Status** **Resolved**
Ratoken team has resolved this issue as suggested and deployed the fixed version to
[0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195 on BSC mainnet.](https://bscscan.com/address/0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195)

Please note that the includeInReward(), setAllFeePercent(), setMaxTxPercent(),
and setMaxWalletPercent() functions have been removed.

#### 5.5.1. Description

Privileged functions that are executable by the controlling parties are not logged properly by emitting events.
Without events, it is not easy for the public to monitor the execution of those privileged functions, allowing
the controlling parties to perform actions that cause big impacts to the platform.

For example, the owner can modify the fees by executing setAllFeePercent() function in the Token
contract, and no event is emitted.

The privileged functions without sufficient logging are as follows:

**File** **Contract** **Function** **Modifier**

Token.sol (L:904) Token excludeFromReward() onlyOwner

Token.sol (L:913) Token includeInReward() onlyOwner

Token.sol (L:927) Token excludeFromFee() onlyOwner

Token.sol (L:931) Token includeInFee() onlyOwner

Token.sol (L:935) Token setAllFeePercent() onlyOwner

Token.sol (L:952) Token setBuybackUpperLimit() onlyOwner

( ) 19

|ID|IDX-005|
|---|---|
|Target|Token|
|Category|Advanced Smart Contract Vulnerability|
|CWE|CWE-778: Insufficient Logging|
|Risk|Severity: Very Low Impact: Low Privileged functions' executions cannot be monitored easily by the users. Likelihood: Low It is not likely that the execution of the privileged functions will be a malicious action.|
|Status|Resolved Ratoken team has resolved this issue as suggested and deployed the fixed version to 0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195 on BSC mainnet. Please note that the includeInReward(), setAllFeePercent(), setMaxTxPercent(), and setMaxWalletPercent() functions have been removed.|

|File|Contract|Function|Modifier|
|---|---|---|---|
|Token.sol (L:904)|Token|excludeFromReward()|onlyOwner|
|Token.sol (L:913)|Token|includeInReward()|onlyOwner|
|Token.sol (L:927)|Token|excludeFromFee()|onlyOwner|
|Token.sol (L:931)|Token|includeInFee()|onlyOwner|
|Token.sol (L:935)|Token|setAllFeePercent()|onlyOwner|
|Token.sol (L:952)|Token|setBuybackUpperLimit()|onlyOwner|


-----

Public

________

Token.sol (L:956) Token setMaxTxPercent() onlyOwner

Token.sol (L:963) Token setMaxWalletPercent() onlyOwner

#### 5.5.2. Remediation

Inspex suggests emitting events for the execution of privileged functions, for example:

**Token.sol**
```
 904 event ExcludeFromReward(address account);
 905 function excludeFromReward(address account) public onlyOwner() {
 906 require(!_isExcluded[account], "Account is already excluded from reward");
 907 if(_rOwned[account] > 0) {
 908 _tOwned[account] = tokenFromReflection(_rOwned[account]);
 909 }
 910 _isExcluded[account] = true;
 911 _excluded.push(account);
 912 emit ExcludeFromReward(account);
 913 }

```
( ) 20

|________|Col2|Col3|Col4|
|---|---|---|---|
|Token.sol (L:956)|Token|setMaxTxPercent()|onlyOwner|
|Token.sol (L:963)|Token|setMaxWalletPercent()|onlyOwner|

|904 905 906 907 908 909 910 911 912 913|event ExcludeFromReward(address account); function excludeFromReward(address account) public onlyOwner() { require(!_isExcluded[account], "Account is already excluded from reward"); if(_rOwned[account] > 0) { _tOwned[account] = tokenFromReflection(_rOwned[account]); } _isExcluded[account] = true; _excluded.push(account); emit ExcludeFromReward(account); }|
|---|---|


-----

Public

________

### 