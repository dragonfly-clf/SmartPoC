Dangerous Unary Expressions (1 Item)

```
|Function|Severity|Remedation|
|---|---|---|
|Mathematical operations in the smart contracts forms the base for all the arithmetic logic in the code. Care should be taken when implementing these because they may control critical function logic, tokens, ether, etc. The contract was found to be incorrectly implementing arithmetic expressions assuming the contract wanted to add the value of a to b and store it back in a. Correct usage: a += b; Incorrect usage: a =+b;|Severity : medium|Developers should exercise caution when writing these expressions because a simple mistake may cause loss of funds or compromise of the contract. Make sure that the expressions used are in the correct format, i.e., a += b; and not a =+b;.|


-----

```
Contract Flow Graph

```

-----

```
Inheritance Graph

```

-----

```
Contract Descriptions

```
**Contract** **File** **Bases**

**Function Name** **Visibility** **Mutability** **Modifiers**

**IERC20** Interface

totalSupply External ❗️ NO❗️

balanceOf External ❗️ NO❗️

transfer External ❗️ 🛑 NO❗️

allowance External ❗️ NO❗️

approve External ❗️ 🛑 NO❗️

transferFrom External ❗️ 🛑 NO❗️

**IERC20Metadat**

Interface IERC20
**a**

name External ❗️ NO❗️

symbol External ❗️ NO❗️

decimals External ❗️ NO❗️

**Context** Implementation

_msgSender Internal 🔒

_msgData Internal 🔒

Context, IERC20,
**ERC20** Implementation
IERC20Metadata

Public ❗️ 🛑 NO❗️

name Public ❗️ NO❗️

symbol Public ❗️ NO❗️

decimals Public ❗️ NO❗️

totalSupply Public ❗️ NO❗️

balanceOf Public ❗️ NO❗️

transfer Public ❗️ 🛑 NO❗️

allowance Public ❗️ NO❗️

approve Public ❗️ 🛑 NO❗️

transferFrom Public ❗️ 🛑 NO❗️

increaseAllowanc

Public ❗️ 🛑 NO❗️
e

|Contract|File|Bases|Col4|Col5|
|---|---|---|---|---|
||Function Name|Visibility|Mutability|Modifiers|
||||||
|IERC20|Interface||||
||totalSupply|External ❗ ️||NO❗ ️|
||balanceOf|External ❗ ️||NO❗ ️|
||transfer|External ❗ ️|🛑|NO❗ ️|
||allowance|External ❗ ️||NO❗ ️|
||approve|External ❗ ️|🛑|NO❗ ️|
||transferFrom|External ❗ ️|🛑|NO❗ ️|
||||||
|IERC20Metadat a|Interface|IERC20|||
||name|External ❗ ️||NO❗ ️|
||symbol|External ❗ ️||NO❗ ️|
||decimals|External ❗ ️||NO❗ ️|
||||||
|Context|Implementation||||
||_msgSender|Internal 🔒|||
||_msgData|Internal 🔒|||
||||||
|ERC20|Implementation|Context, IERC20, IERC20Metadata|||
|||Public ❗ ️|🛑|NO❗ ️|
||name|Public ❗ ️||NO❗ ️|
||symbol|Public ❗ ️||NO❗ ️|
||decimals|Public ❗ ️||NO❗ ️|
||totalSupply|Public ❗ ️||NO❗ ️|
||balanceOf|Public ❗ ️||NO❗ ️|
||transfer|Public ❗ ️|🛑|NO❗ ️|
||allowance|Public ❗ ️||NO❗ ️|
||approve|Public ❗ ️|🛑|NO❗ ️|
||transferFrom|Public ❗ ️|🛑|NO❗ ️|


-----

|Col1|decreaseAllowan ce|Public ❗ ️|🛑|NO❗ ️|
|---|---|---|---|---|
||_transfer|Internal 🔒|🛑||
||_mint|Internal 🔒|🛑||
||_burn|Internal 🔒|🛑||
||_approve|Internal 🔒|🛑||
||_beforeTokenTra nsfer|Internal 🔒|🛑||
||_afterTokenTrans fer|Internal 🔒|🛑||
||||||
|Ownable|Implementation|Context|||
|||Public ❗ ️|🛑|NO❗ ️|
||owner|Public ❗ ️||NO❗ ️|
||renounceOwners hip|Public ❗ ️|🛑|onlyOwner|
||transferOwnershi p|Public ❗ ️|🛑|onlyOwner|
||_setOwner|Private 🔐|🛑||
||||||
|SafeMath|Library||||
||tryAdd|Internal 🔒|||
||trySub|Internal 🔒|||
||tryMul|Internal 🔒|||
||tryDiv|Internal 🔒|||
||tryMod|Internal 🔒|||
||add|Internal 🔒|||
||sub|Internal 🔒|||
||mul|Internal 🔒|||
||div|Internal 🔒|||
||mod|Internal 🔒|||
||sub|Internal 🔒|||
||div|Internal 🔒|||
||mod|Internal 🔒|||
||||||
|Clones|Library||||
||clone|Internal 🔒|🛑||
||cloneDeterminist ic|Internal 🔒|🛑||
||predictDetermini sticAddress|Internal 🔒|||


-----

|Col1|predictDetermini sticAddress|Internal 🔒|Col4|Col5|
|---|---|---|---|---|
||||||
|Address|Library||||
||isContract|Internal 🔒|||
||sendValue|Internal 🔒|🛑||
||functionCall|Internal 🔒|🛑||
||functionCall|Internal 🔒|🛑||
||functionCallWith Value|Internal 🔒|🛑||
||functionCallWith Value|Internal 🔒|🛑||
||functionStaticCal l|Internal 🔒|||
||functionStaticCal l|Internal 🔒|||
||functionDelegate Call|Internal 🔒|🛑||
||functionDelegate Call|Internal 🔒|🛑||
||verifyCallResult|Internal 🔒|||
||||||
|IUniswapV2Fact ory|Interface||||
||feeTo|External ❗ ️||NO❗ ️|
||feeToSetter|External ❗ ️||NO❗ ️|
||getPair|External ❗ ️||NO❗ ️|
||allPairs|External ❗ ️||NO❗ ️|
||allPairsLength|External ❗ ️||NO❗ ️|
||createPair|External ❗ ️|🛑|NO❗ ️|
||setFeeTo|External ❗ ️|🛑|NO❗ ️|
||setFeeToSetter|External ❗ ️|🛑|NO❗ ️|
||||||
|IUniswapV2Rou ter01|Interface||||
||factory|External ❗ ️||NO❗ ️|
||WETH|External ❗ ️||NO❗ ️|
||addLiquidity|External ❗ ️|🛑|NO❗ ️|
||addLiquidityETH|External ❗ ️|💵|NO❗ ️|
||removeLiquidity|External ❗ ️|🛑|NO❗ ️|
||removeLiquidityE TH|External ❗ ️|🛑|NO❗ ️|


-----

|Col1|removeLiquidity WithPermit|External ❗ ️|🛑|NO❗ ️|
|---|---|---|---|---|
||removeLiquidityE THWithPermit|External ❗ ️|🛑|NO❗ ️|
||swapExactToken sForTokens|External ❗ ️|🛑|NO❗ ️|
||swapTokensForE xactTokens|External ❗ ️|🛑|NO❗ ️|
||swapExactETHFo rTokens|External ❗ ️|💵|NO❗ ️|
||swapTokensForE xactETH|External ❗ ️|🛑|NO❗ ️|
||swapExactToken sForETH|External ❗ ️|🛑|NO❗ ️|
||swapETHForExac tTokens|External ❗ ️|💵|NO❗ ️|
||quote|External ❗ ️||NO❗ ️|
||getAmountOut|External ❗ ️||NO❗ ️|
||getAmountIn|External ❗ ️||NO❗ ️|
||getAmountsOut|External ❗ ️||NO❗ ️|
||getAmountsIn|External ❗ ️||NO❗ ️|
||||||
|IUniswapV2Rou ter02|Interface|IUniswapV2Rout er01|||
||removeLiquidityE THSupportingFe eOnTransferToke ns|External ❗ ️|🛑|NO❗ ️|
||removeLiquidityE THWithPermitSu pportingFeeOnTr ansferTokens|External ❗ ️|🛑|NO❗ ️|
||swapExactToken sForTokensSupp ortingFeeOnTran sferTokens|External ❗ ️|🛑|NO❗ ️|
||swapExactETHFo rTokensSupporti ngFeeOnTransfer Tokens|External ❗ ️|💵|NO❗ ️|


-----

|Col1|swapExactToken sForETHSupporti ngFeeOnTransfer Tokens|External ❗ ️|🛑|NO❗ ️|
|---|---|---|---|---|
||||||
|IERC20Upgrade able|Interface||||
||totalSupply|External ❗ ️||NO❗ ️|
||balanceOf|External ❗ ️||NO❗ ️|
||transfer|External ❗ ️|🛑|NO❗ ️|
||allowance|External ❗ ️||NO❗ ️|
||approve|External ❗ ️|🛑|NO❗ ️|
||transferFrom|External ❗ ️|🛑|NO❗ ️|
||||||
|IERC20Metadat aUpgradeable|Interface|IERC20Upgradea ble|||
||name|External ❗ ️||NO❗ ️|
||symbol|External ❗ ️||NO❗ ️|
||decimals|External ❗ ️||NO❗ ️|
||||||
|Initializable|Implementation||||
||||||
|ContextUpgrad eable|Implementation|Initializable|||
||__Context_init|Internal 🔒|🛑|initializer|
||__Context_init_u nchained|Internal 🔒|🛑|initializer|
||_msgSender|Internal 🔒|||
||_msgData|Internal 🔒|||
||||||
|ERC20Upgradea ble|Implementation|Initializable, ContextUpgrade able, IERC20Upgradea ble, IERC20Metadata Upgradeable|||
||__ERC20_init|Internal 🔒|🛑|initializer|


__ERC20_init_unc

Internal 🔒 🛑 initializer
hained


-----

|Col1|name|Public ❗ ️|Col4|NO❗ ️|
|---|---|---|---|---|
||symbol|Public ❗ ️||NO❗ ️|
||decimals|Public ❗ ️||NO❗ ️|
||totalSupply|Public ❗ ️||NO❗ ️|
||balanceOf|Public ❗ ️||NO❗ ️|
||transfer|Public ❗ ️|🛑|NO❗ ️|
||allowance|Public ❗ ️||NO❗ ️|
||approve|Public ❗ ️|🛑|NO❗ ️|
||transferFrom|Public ❗ ️|🛑|NO❗ ️|
||increaseAllowanc e|Public ❗ ️|🛑|NO❗ ️|
||decreaseAllowan ce|Public ❗ ️|🛑|NO❗ ️|
||_transfer|Internal 🔒|🛑||
||_mint|Internal 🔒|🛑||
||_burn|Internal 🔒|🛑||
||_approve|Internal 🔒|🛑||
||_beforeTokenTra nsfer|Internal 🔒|🛑||
||_afterTokenTrans fer|Internal 🔒|🛑||
||||||
|OwnableUpgra deable|Implementation|Initializable, ContextUpgrade able|||
||__Ownable_init|Internal 🔒|🛑|initializer|
||__Ownable_init_u nchained|Internal 🔒|🛑|initializer|
||owner|Public ❗ ️||NO❗ ️|
||renounceOwners hip|Public ❗ ️|🛑|onlyOwner|
||transferOwnershi p|Public ❗ ️|🛑|onlyOwner|
||_setOwner|Private 🔐|🛑||
||||||
|IUniswapV2Pair|Interface||||
||name|External ❗ ️||NO❗ ️|
||symbol|External ❗ ️||NO❗ ️|
||decimals|External ❗ ️||NO❗ ️|
||totalSupply|External ❗ ️||NO❗ ️|


balanceOf External ❗️ NO❗️


-----

|Col1|allowance|External ❗ ️|Col4|NO❗ ️|
|---|---|---|---|---|
||approve|External ❗ ️|🛑|NO❗ ️|
||transfer|External ❗ ️|🛑|NO❗ ️|
||transferFrom|External ❗ ️|🛑|NO❗ ️|
||DOMAIN_SEPAR ATOR|External ❗ ️||NO❗ ️|
||PERMIT_TYPEHA SH|External ❗ ️||NO❗ ️|
||nonces|External ❗ ️||NO❗ ️|
||permit|External ❗ ️|🛑|NO❗ ️|
||MINIMUM_LIQUI DITY|External ❗ ️||NO❗ ️|
||factory|External ❗ ️||NO❗ ️|
||token0|External ❗ ️||NO❗ ️|
||token1|External ❗ ️||NO❗ ️|
||getReserves|External ❗ ️||NO❗ ️|
||price0Cumulativ eLast|External ❗ ️||NO❗ ️|
||price1Cumulativ eLast|External ❗ ️||NO❗ ️|
||kLast|External ❗ ️||NO❗ ️|
||mint|External ❗ ️|🛑|NO❗ ️|
||burn|External ❗ ️|🛑|NO❗ ️|
||swap|External ❗ ️|🛑|NO❗ ️|
||skim|External ❗ ️|🛑|NO❗ ️|
||sync|External ❗ ️|🛑|NO❗ ️|
||initialize|External ❗ ️|🛑|NO❗ ️|
||||||
|SafeMathInt|Library||||
||mul|Internal 🔒|||
||div|Internal 🔒|||
||sub|Internal 🔒|||
||add|Internal 🔒|||
||abs|Internal 🔒|||
||toUint256Safe|Internal 🔒|||
||||||
|SafeMathUint|Library||||
||toInt256Safe|Internal 🔒|||
||||||
|IterableMappin g|Library||||


get Public ❗️ NO❗️


-----

|Col1|getIndexOfKey|Public ❗ ️|Col4|NO❗ ️|
|---|---|---|---|---|
||getKeyAtIndex|Public ❗ ️||NO❗ ️|
||size|Public ❗ ️||NO❗ ️|
||set|Public ❗ ️|🛑|NO❗ ️|
||remove|Public ❗ ️|🛑|NO❗ ️|
||||||
|DividendPaying TokenInterface|Interface||||
||dividendOf|External ❗ ️||NO❗ ️|
||withdrawDividen d|External ❗ ️|🛑|NO❗ ️|
||||||
|DividendPaying TokenOptionalI nterface|Interface||||
||withdrawableDivi dendOf|External ❗ ️||NO❗ ️|
||withdrawnDivide ndOf|External ❗ ️||NO❗ ️|
||accumulativeDivi dendOf|External ❗ ️||NO❗ ️|
||||||
|DividendPaying Token|Implementation|ERC20Upgradea ble, OwnableUpgrad eable, DividendPayingT okenInterface, DividendPayingT okenOptionalInt erface|||
||__DividendPayin gToken_init|Internal 🔒|🛑|initializer|
||distributeCAKEDi vidends|Public ❗ ️|🛑|onlyOwner|
||withdrawDividen d|Public ❗ ️|🛑|NO❗ ️|
||_withdrawDivide ndOfUser|Internal 🔒|🛑||


-----

|Col1|dividendOf|Public ❗ ️|Col4|NO❗ ️|
|---|---|---|---|---|
||withdrawableDivi dendOf|Public ❗ ️||NO❗ ️|
||withdrawnDivide ndOf|Public ❗ ️||NO❗ ️|
||accumulativeDivi dendOf|Public ❗ ️||NO❗ ️|
||_transfer|Internal 🔒|🛑||
||_mint|Internal 🔒|🛑||
||_burn|Internal 🔒|🛑||
||_setBalance|Internal 🔒|🛑||
||||||
|BABYTOKENDiv idendTracker|Implementation|OwnableUpgrad eable, DividendPayingT oken|||
||initialize|External ❗ ️|🛑|initializer|
||_transfer|Internal 🔒|||
||withdrawDividen d|Public ❗ ️||NO❗ ️|
||excludeFromDivi dends|External ❗ ️|🛑|onlyOwner|
||isExcludedFromD ividends|Public ❗ ️||NO❗ ️|
||updateClaimWai t|External ❗ ️|🛑|onlyOwner|
||updateMinimum TokenBalanceFor Dividends|External ❗ ️|🛑|onlyOwner|
||getLastProcesse dIndex|External ❗ ️||NO❗ ️|
||getNumberOfTo kenHolders|External ❗ ️||NO❗ ️|
||getAccount|Public ❗ ️||NO❗ ️|
||getAccountAtInd ex|Public ❗ ️||NO❗ ️|
||canAutoClaim|Private 🔐|||
||setBalance|External ❗ ️|🛑|onlyOwner|
||process|Public ❗ ️|🛑|NO❗ ️|
||processAccount|Public ❗ ️|🛑|onlyOwner|
||||||


-----

|BaseToken|Implementation|Col3|Col4|Col5|
|---|---|---|---|---|
||||||
|BABYTOKEN|Implementation|ERC20, Ownable, BaseToken|||
|||Public ❗ ️|💵|ERC20|
|||External ❗ ️|💵|NO❗ ️|
||setSwapTokensA tAmount|External ❗ ️|🛑|onlyOwner|
||excludeFromFee s|External ❗ ️|🛑|onlyOwner|
||excludeMultiple AccountsFromFe es|External ❗ ️|🛑|onlyOwner|
||setMarketingWal let|External ❗ ️|🛑|onlyOwner|
||setTokenReward sFee|External ❗ ️|🛑|onlyOwner|
||setLiquiditFee|External ❗ ️|🛑|onlyOwner|
||setMarketingFee|External ❗ ️|🛑|onlyOwner|
||_setAutomatedM arketMakerPair|Private 🔐|🛑||
||updateGasForPr ocessing|Public ❗ ️|🛑|onlyOwner|
||updateClaimWai t|External ❗ ️|🛑|onlyOwner|
||getClaimWait|External ❗ ️||NO❗ ️|
||updateMinimum TokenBalanceFor Dividends|External ❗ ️|🛑|onlyOwner|
||getMinimumTok enBalanceForDivi dends|External ❗ ️||NO❗ ️|
||getTotalDividend sDistributed|External ❗ ️||NO❗ ️|
||isExcludedFromF ees|Public ❗ ️||NO❗ ️|
||withdrawableDivi dendOf|Public ❗ ️||NO❗ ️|
||dividendTokenBa lanceOf|Public ❗ ️||NO❗ ️|


excludeFromDivi

External ❗️ 🛑 onlyOwner
dends


-----

|Col1|isExcludedFromD ividends|Public ❗ ️|Col4|NO❗ ️|
|---|---|---|---|---|
||getAccountDivid endsInfo|External ❗ ️||NO❗ ️|
||getAccountDivid endsInfoAtIndex|External ❗ ️||NO❗ ️|
||processDividend Tracker|External ❗ ️|🛑|NO❗ ️|
||claim|External ❗ ️|🛑|NO❗ ️|
||getLastProcesse dIndex|External ❗ ️||NO❗ ️|
||getNumberOfDiv idendTokenHold ers|External ❗ ️||NO❗ ️|
||_transfer|Internal 🔒|🛑||
||swapAndSendTo Fee|Private 🔐|🛑||
||swapAndLiquify|Private 🔐|🛑||
||swapTokensForE th|Private 🔐|🛑||
||swapTokensForC ake|Private 🔐|🛑||
||addLiquidity|Private 🔐|🛑||
||swapAndSendDi vidends|Private 🔐|🛑||


Function
can modify

state


Function
is payable

```
Source:
File Name SHA-1 Hash
c:\Solidity\babyltc.sol b4e69c7c64c78595cd52c4f5dba4be96d2bb96c4

```

-----

```
Audit Scope
Audit Method.
Our smart contract audit is an extensive methodical examination and
analysis of the smart contract’s code that is used to interact with
the blockchain. Goal: discover errors, issues and security
vulnaribilities in the code. Findings getting reported and
improvements getting suggested.
Automatic and Manual Review
We are using automated tools to scan functions and weeknesses of the
contract. Transfers, integer over-undeflow checks such as all CWE
events.
Tools we use: 
Visual Studio Code
CWE
SWC
Solidity Scan
SVD
In manual code review our auditor looking at source code and
performing line by line examination. This method helps to clarify
developer’s coding decisions and business logic.
Skeleton Ecosystem
https://skeletonecosystem.com
https://github.com/SkeletonEcosystem/Audits

