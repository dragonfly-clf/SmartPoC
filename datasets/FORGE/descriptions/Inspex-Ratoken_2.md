5.3. Centralized Control of State Variable

**ID** IDX-003

**Target** Token

**Category** General Smart Contract Vulnerability

**CWE** CWE-710: Improper Adherence to Coding Standard

**Risk** **Severity: Low**

**Impact: Low**
The controlling authorities can change the critical state variables to gain additional profit.
Thus, it is unfair to the other users.

**Likelihood: Medium**
There is nothing to restrict the changes from being done by the owner; however, the
changes are limited by fixed values in the smart contracts.

**Status** **Acknowledged**
Ratoken team has acknowledged this issue. The team has decided to remove the
```
       includeInReward(), setAllFeePercent(), setMaxTxPercent(), and
       setMaxWalletPercent() functions that have high impact to the users and deployed the

```
[modified version to 0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195 on BSC mainnet.](https://bscscan.com/address/0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195)

Therefore, Inspex has adjusted the impact and severity of this issue from Medium to Low.

#### 5.3.1. Description

Critical state variables can be updated any time by the controlling authorities. Changes in these variables can
cause impacts to the users, so the users should accept or be notified before these changes are effective.

There is currently no constraint to prevent the authorities from modifying these variables without notifying
the users.

The controllable privileged state update functions are as follows:

**File** **Contract** **Function** **Inherit From** **Modifier**

Token.sol (L:503) Token renounceOwnership() Ownable onlyOwner

Token.sol (L:512) Token transferOwnership() Ownable onlyOwner

Token.sol (L:523) Token lock() Ownable onlyOwner

Token.sol (L:904) Token excludeFromReward() - onlyOwner

Token.sol (L:913) Token includeInReward() - onlyOwner

( ) 14

|ID|IDX-003|
|---|---|
|Target|Token|
|Category|General Smart Contract Vulnerability|
|CWE|CWE-710: Improper Adherence to Coding Standard|
|Risk|Severity: Low Impact: Low The controlling authorities can change the critical state variables to gain additional profit. Thus, it is unfair to the other users. Likelihood: Medium There is nothing to restrict the changes from being done by the owner; however, the changes are limited by fixed values in the smart contracts.|
|Status|Acknowledged Ratoken team has acknowledged this issue. The team has decided to remove the includeInReward(), setAllFeePercent(), setMaxTxPercent(), and setMaxWalletPercent() functions that have high impact to the users and deployed the modified version to 0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195 on BSC mainnet. Therefore, Inspex has adjusted the impact and severity of this issue from Medium to Low.|

|File|Contract|Function|Inherit From|Modifier|
|---|---|---|---|---|
|Token.sol (L:503)|Token|renounceOwnership()|Ownable|onlyOwner|
|Token.sol (L:512)|Token|transferOwnership()|Ownable|onlyOwner|
|Token.sol (L:523)|Token|lock()|Ownable|onlyOwner|
|Token.sol (L:904)|Token|excludeFromReward()|-|onlyOwner|
|Token.sol (L:913)|Token|includeInReward()|-|onlyOwner|


-----

Public

________

Token.sol (L:927) Token excludeFromFee() - onlyOwner

Token.sol (L:931) Token includeInFee() - onlyOwner

Token.sol (L:935) Token setAllFeePercent() - onlyOwner

Token.sol (L:952) Token setBuybackUpperLimit() - onlyOwner

Token.sol (L:956) Token setMaxTxPercent() - onlyOwner

Token.sol (L:963) Token setMaxWalletPercent() - onlyOwner

Token.sol (L:970) Token setSwapAndLiquifyEnabled() - onlyOwner

Token.sol (L:975) Token setFeeWallet() - onlyOwner

#### 5.3.2. Remediation

In the ideal case, the critical state variables should not be modifiable to keep the integrity of the smart
contract. However, if modifications are needed, Inspex suggests limiting the use of these functions via the
following options:

   - Implementing a community-run governance to control the use of these functions
   - Using a Timelock contract to delay the changes for a sufficient amount of time, e.g., 24 hours

( ) 15

|________|Col2|Col3|Col4|Col5|
|---|---|---|---|---|
|Token.sol (L:927)|Token|excludeFromFee()|-|onlyOwner|
|Token.sol (L:931)|Token|includeInFee()|-|onlyOwner|
|Token.sol (L:935)|Token|setAllFeePercent()|-|onlyOwner|
|Token.sol (L:952)|Token|setBuybackUpperLimit()|-|onlyOwner|
|Token.sol (L:956)|Token|setMaxTxPercent()|-|onlyOwner|
|Token.sol (L:963)|Token|setMaxWalletPercent()|-|onlyOwner|
|Token.sol (L:970)|Token|setSwapAndLiquifyEnabled()|-|onlyOwner|
|Token.sol (L:975)|Token|setFeeWallet()|-|onlyOwner|


-----

Public

________

### 