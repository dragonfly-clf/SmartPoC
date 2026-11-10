5.4. Division Before Multiplication

**ID** IDX-004

**Target** Token

**Category** General Smart Contract Vulnerability

**CWE** CWE-682: Incorrect Calculation

**Risk** **Severity: Low**

**Impact: Low**
The rounding error can cause the fees to be slightly miscalculated.

**Likelihood: Medium**
It is likely that the balance divided by each fee can result in a decimal value.

**Status** **Resolved**
Ratoken team has resolved this issue as suggested and deployed the fixed version to
[0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195 on BSC mainnet.](https://bscscan.com/address/0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195)

#### 5.4.1. Description

Solidity supports only integer values but not floating point values. The division of integers can result in a
value with decimal points, which will be rounded off. This rounding error can cause the calculation to be
different from what it should be, especially when that value is later multiplied with another value.

For example, in line 1153, the spentAmount is calculated by dividing contractTokenBalance with totFee,
before multiplying it by _burnFee. The rounding error caused by the division is amplified in the
multiplication, and can increase the amount of miscalculation.

**Token.sol**
```
 1146 function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
 1147 //This needs to be distributed among burn, wallet and liquidity
 1148 //burn
 1149 uint8 totFee = _burnFee + _walletFee + _liquidityFee + _buybackFee;
 1150 uint256 spentAmount = 0;
 1151 uint256 totSpentAmount = 0;
 1152 if(_burnFee != 0){
 1153 spentAmount = contractTokenBalance.div(totFee).mul(_burnFee);
 1154 _tokenTransferNoFee(address(this), dead, spentAmount);
 1155 totSpentAmount = spentAmount;
 1156 }

```
The lines of code with division before multiplication are as follows:

   - Token.sol (L:1153)

( ) 16

|ID|IDX-004|
|---|---|
|Target|Token|
|Category|General Smart Contract Vulnerability|
|CWE|CWE-682: Incorrect Calculation|
|Risk|Severity: Low Impact: Low The rounding error can cause the fees to be slightly miscalculated. Likelihood: Medium It is likely that the balance divided by each fee can result in a decimal value.|
|Status|Resolved Ratoken team has resolved this issue as suggested and deployed the fixed version to 0x43c612590Ad7Ac3f5fc217Bf71487B49A034E195 on BSC mainnet.|

|1146 1147 1148 1149 1150 1151 1152 1153 1154 1155 1156|function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap { //This needs to be distributed among burn, wallet and liquidity //burn uint8 totFee = _burnFee + _walletFee + _liquidityFee + _buybackFee; uint256 spentAmount = 0; uint256 totSpentAmount = 0; if(_burnFee != 0){ spentAmount = contractTokenBalance.div(totFee).mul(_burnFee); _tokenTransferNoFee(address(this), dead, spentAmount); totSpentAmount = spentAmount; }|
|---|---|


-----

Public

________

   - Token.sol (L:1159)
   - Token.sol (L:1165)

#### 5.4.2. Remediation

Inspex suggests modifying the affected lines of code to perform multiplication before division, for example:

**Token.sol**
```
 1146 function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
 1147 //This needs to be distributed among burn, wallet and liquidity
 1148 //burn
 1149 uint8 totFee = _burnFee + _walletFee + _liquidityFee + _buybackFee;
 1150 uint256 spentAmount = 0;
 1151 uint256 totSpentAmount = 0;
 1152 if(_burnFee != 0){
 1153 spentAmount = contractTokenBalance.mul(_burnFee).div(totFee);
 1154 _tokenTransferNoFee(address(this), dead, spentAmount);
 1155 totSpentAmount = spentAmount;
 1156 }
 1157
 1158 if(_walletFee != 0){
 1159 spentAmount = contractTokenBalance.mul(_walletFee).div(totFee);
 1160 _tokenTransferNoFee(address(this), feeWallet, spentAmount);
 1161 totSpentAmount = totSpentAmount + spentAmount;
 1162 }
 1163
 1164 if(_buybackFee != 0){
 1165 spentAmount = contractTokenBalance.mul(_buybackFee).div(totFee);
 1166 swapTokensForBNB(spentAmount);
 1167 totSpentAmount = totSpentAmount + spentAmount;
 1168 }
 1169
 1170 if(_liquidityFee != 0){
 1171 contractTokenBalance = contractTokenBalance.sub(totSpentAmount);
 1172
 1173 // split the contract balance into halves
 1174 uint256 half = contractTokenBalance.div(2);
 1175 uint256 otherHalf = contractTokenBalance.sub(half);
 1176
 1177 // capture the contract's current ETH balance.
 1178 // this is so that we can capture exactly the amount of ETH that the
 1179 // swap creates, and not make the liquidity event include any ETH that
 1180 // has been manually sent to the contract
 1181 uint256 initialBalance = address(this).balance;
 1182
 1183 // swap tokens for ETH
 1184 swapTokensForBNB(half); // <- this breaks the ETH -> HATE swap when
   swap+liquify is triggered

```
( ) 17

|1146 1147 1148 1149 1150 1151 1152 1153 1154 1155 1156 1157 1158 1159 1160 1161 1162 1163 1164 1165 1166 1167 1168 1169 1170 1171 1172 1173 1174 1175 1176 1177 1178 1179 1180 1181 1182 1183 1184|function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap { //This needs to be distributed among burn, wallet and liquidity //burn uint8 totFee = _burnFee + _walletFee + _liquidityFee + _buybackFee; uint256 spentAmount = 0; uint256 totSpentAmount = 0; if(_burnFee != 0){ spentAmount = contractTokenBalance.mul(_burnFee).div(totFee); _tokenTransferNoFee(address(this), dead, spentAmount); totSpentAmount = spentAmount; } if(_walletFee != 0){ spentAmount = contractTokenBalance.mul(_walletFee).div(totFee); _tokenTransferNoFee(address(this), feeWallet, spentAmount); totSpentAmount = totSpentAmount + spentAmount; } if(_buybackFee != 0){ spentAmount = contractTokenBalance.mul(_buybackFee).div(totFee); swapTokensForBNB(spentAmount); totSpentAmount = totSpentAmount + spentAmount; } if(_liquidityFee != 0){ contractTokenBalance = contractTokenBalance.sub(totSpentAmount); // split the contract balance into halves uint256 half = contractTokenBalance.div(2); uint256 otherHalf = contractTokenBalance.sub(half); // capture the contract's current ETH balance. // this is so that we can capture exactly the amount of ETH that the // swap creates, and not make the liquidity event include any ETH that // has been manually sent to the contract uint256 initialBalance = address(this).balance; // swap tokens for ETH swapTokensForBNB(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered|
|---|---|


-----

Public

________

|1185 1186 1187 1188 1189 1190 1191 1192 1193 1194 1195|// how much ETH did we just swap into? uint256 newBalance = address(this).balance.sub(initialBalance); // add liquidity to uniswap addLiquidity(otherHalf, newBalance); emit SwapAndLiquify(half, newBalance, otherHalf); } }|
|---|---|


( ) 18


-----

Public

________

### 