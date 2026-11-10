Function Signatures
```
48760858 => onPreTransferCheck(address,address,uint256)
884557bf => tryAdd(uint256,uint256)
a29962b1 => trySub(uint256,uint256)
6281efa4 => tryMul(uint256,uint256)
736ecb18 => tryDiv(uint256,uint256)
38dc0867 => tryMod(uint256,uint256)
771602f7 => add(uint256,uint256)
b67d77c5 => sub(uint256,uint256)
c8a4ac9c => mul(uint256,uint256)
a391c15b => div(uint256,uint256)
f43f523a => mod(uint256,uint256)
e31bdc0a => sub(uint256,uint256,string)
b745d336 => div(uint256,uint256,string)
71af23e8 => mod(uint256,uint256,string)
c9c65396 => createPair(address,address)
c45a0155 => factory()
ad5c4648 => WETH()
f305d719 => addLiquidityETH(address,uint256,uint256,uint256,address,uint256)
b6f9de95 => swapExactETHForTokensSupportingFeeOnTransferTokens(uint256,address[],address,uint256)
791ac947 => 
swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)
18160ddd => totalSupply()
313ce567 => decimals()
95d89b41 => symbol()
06fdde03 => name()
70a08231 => balanceOf(address)
a9059cbb => transfer(address,uint256)
dd62ed3e => allowance(address,address)
095ea7b3 => approve(address,uint256)
23b872dd => transferFrom(address,address,uint256)
b6a5d7de => authorize(address)
f0b37c04 => unauthorize(address)
2f54bf6e => isOwner(address)
fe9fbb80 => isAuthorized(address)
f2fde38b => transferOwnership(address)
18e02bd9 => setTokenOwner(address)
2d48e896 => setDistributionCriteria(uint256,uint256)
14b6ca96 => setShare(address,uint256)
d0e30db0 => deposit()
ffb2c479 => process(uint256)
15f7e05e => claimDividend(address)
52f48158 => getPaidEarnings(address)
28fd3198 => getUnpaidEarnings(address)
efca2eed => totalDistributed()
8c21cd52 => shouldDistribute(address)

```
```
a29962b1 => trySub(uint256,uint256)
6281efa4 => tryMul(uint256,uint256)
736ecb18 => tryDiv(uint256,uint256)
38dc0867 => tryMod(uint256,uint256)
771602f7 => add(uint256,uint256)
b67d77c5 => sub(uint256,uint256)
c8a4ac9c => mul(uint256,uint256)
a391c15b => div(uint256,uint256)
f43f523a => mod(uint256,uint256)
e31bdc0a => sub(uint256,uint256,string)
b745d336 => div(uint256,uint256,string)
71af23e8 => mod(uint256,uint256,string)
c9c65396 => createPair(address,address)
c45a0155 => factory()
ad5c4648 => WETH()
f305d719 => addLiquidityETH(address,uint256,uint256,uint256,address,uint256)
b6f9de95 => swapExactETHForTokensSupportingFeeOnTransferTokens(uint256,address[],address,uint256)
791ac947 => 
swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)
18160ddd => totalSupply()
313ce567 => decimals()
95d89b41 => symbol()
06fdde03 => name()
70a08231 => balanceOf(address)
a9059cbb => transfer(address,uint256)
dd62ed3e => allowance(address,address)
095ea7b3 => approve(address,uint256)
23b872dd => transferFrom(address,address,uint256)
b6a5d7de => authorize(address)
f0b37c04 => unauthorize(address)
2f54bf6e => isOwner(address)
fe9fbb80 => isAuthorized(address)
f2fde38b => transferOwnership(address)
18e02bd9 => setTokenOwner(address)
2d48e896 => setDistributionCriteria(uint256,uint256)
14b6ca96 => setShare(address,uint256)
d0e30db0 => deposit()

```

-----

```
5319504a => distributeDividend(address)
e68af3ac => getCumulativeDividends(uint256)
db29fe12 => addShareholder(address)
9babdad6 => removeShareholder(address)
571ac8b0 => approveMax(address)
cb712535 => _transferFrom(address,address,uint256)
f0774e71 => _basicTransfer(address,address,uint256)
e7c44c69 => shouldTakeFee(address)
1d759aae => takeFee(address,uint256)
d4cabfbe => setBuyAccFee(uint256)
1ca21cfc => setSellAccFee(uint256)
0d5c6cea => shouldSwapBack()
6ac5eeee => swapBack()
f0fc6bca => claimDividend()
49bc3feb => getPaidDividend(address)
86db0c05 => getUnpaidDividend(address)
1961cee2 => getTotalDistributedDividend()
c57f8cfb => setAntiBot(address,bool)
f708a64f => setIsDividendExempt(address,bool)
658d4b7f => setIsFeeExempt(address,bool)
47a28b79 => setBuyFees(uint256,uint256,uint256,uint256,uint256)
c1cf53c4 => setSellFees(uint256,uint256,uint256,uint256,uint256)
d7c01032 => setFeeReceivers(address,address,address)
df20fd49 => setSwapBackSettings(bool,uint256)
201e7991 => setTargetLiquidity(uint256,uint256)
9d1944f5 => setDistributorSettings(uint256)
2b112e49 => getCirculatingSupply()
d51ed1c8 => getLiquidityBacking(uint256)
1161ae39 => isOverLiquified(uint256,uint256)

```
```
e7c44c69 => shouldTakeFee(address)
1d759aae => takeFee(address,uint256)
d4cabfbe => setBuyAccFee(uint256)
1ca21cfc => setSellAccFee(uint256)
0d5c6cea => shouldSwapBack()
6ac5eeee => swapBack()
f0fc6bca => claimDividend()
49bc3feb => getPaidDividend(address)
86db0c05 => getUnpaidDividend(address)
1961cee2 => getTotalDistributedDividend()
c57f8cfb => setAntiBot(address,bool)
f708a64f => setIsDividendExempt(address,bool)
658d4b7f => setIsFeeExempt(address,bool)
47a28b79 => setBuyFees(uint256,uint256,uint256,uint256,uint256)
c1cf53c4 => setSellFees(uint256,uint256,uint256,uint256,uint256)
d7c01032 => setFeeReceivers(address,address,address)
df20fd49 => setSwapBackSettings(bool,uint256)
201e7991 => setTargetLiquidity(uint256,uint256)
9d1944f5 => setDistributorSettings(uint256)
2b112e49 => getCirculatingSupply()
d51ed1c8 => getLiquidityBacking(uint256)
1161ae39 => isOverLiquified(uint256,uint256)

```

-----

## Inheritance Graph


-----

# Manual Analysis

**Function** **Description** **Available** **Status**

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

executes fee collection from swap events and/or

**Contract Fees** Yes **Passed**

transfer events

stops some or all bot wallets from interacting

**Anti Bot** Yes **Passed**

with the smart contract

executes transfer of contract ownership to a

**Transfer Ownership** Yes **Passed**

specified wallet

**Renounce** executes transfer of contract ownership to a

Yes **Passed**

**Ownership** dead address


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

executes fee collection from swap events and/or

**Contract Fees** Yes **Passed**

transfer events

stops some or all bot wallets from interacting

**Anti Bot** Yes **Passed**

with the smart contract

executes transfer of contract ownership to a

**Transfer Ownership** Yes **Passed**

specified wallet

**Renounce** executes transfer of contract ownership to a

Yes **Passed**

**Ownership** dead address


-----

## 