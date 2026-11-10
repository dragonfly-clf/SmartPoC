### Medium severity issues

###### 1. Fees is not restored after a special fee transaction

 Line Code

 754-789 // Buy if(from == uniswapV2Pair){   removeAllFee();   _taxFee = _buyTaxFee;     _liquidityFee = _buyLiquidityFee; } // Sell if(to == uniswapV2Pair){   removeAll …… …… …….
     if(from == uniswapV2Pair){             _taxFee = _addressFees[to]._buyTaxFee;       _liquidityFee = _addressFees[to]._buyLiquidityFee;     }   }

 Description After a user with special fee enabled does a transaction, any following transactions will also have the same _taxFee and _liquidityFee which this user is charged. This happens because the removeAllFee() function removes the fees and stores it in variables to restore later. But it is never restored after the transaction.
 Remediation Restore the fee after the transaction with the special fee is complete.

 Status: Open The transactions, after a special fee transaction, are still charged the same fee.

 05


-----

|Line|Code|
|---|---|
|1029-1045 for (uint256 j = 0; j < _sellHistories.length; j ++) { if (_sellHistories[j].time >= maxStartTimeForHistories) { _sellHistories[i].time = _sellHistories[j].time; _sellHistories[i].bnbAmount = _sellHistories[j].bnbAmount; i = i + 1; } } uint256 removedCnt = _sellHistories.length - i; for (uint256 j = 0; j < removedCnt; j ++) { _sellHistories.pop(); }||


###### 2. Costly loops leading to DOS attack

 Line Code

 1029-1045 for (uint256 j = 0; j < _sellHistories.length; j ++) {
   if (_sellHistories[j].time >= maxStartTimeForHistories) {
     _sellHistories[i].time = _sellHistories[j].time;         _sellHistories[i].bnbAmount = _sellHistories[j].bnbAmount;
     i = i + 1;   } }
 uint256 removedCnt = _sellHistories.length - i;
 for (uint256 j = 0; j < removedCnt; j ++) {
   _sellHistories.pop(); }

 Description The _sellHistories[] array is used in a for loop in the _removeOldSellHistories() function. Elements are inserted into this array, whenever there is a transfer of tokens to the UniswapV2Pair address. This can be done by any user multiple times to increase the array size. 
 Whenever _removeOldSellHistories() function is called, the array is traversed, and some elements are updated. If the size of the array is very large, the transaction’s gas usage will exceed the block gas limit, and the transaction will fail. 
 Remediation We recommend having a check on the size of _sellHistories[] array. The logic in the _removeOldSellHistories() function should be changed to prevent such a scenario.

 0506


-----

|Line|Code|
|---|---|
|691-697 if (to == uniswapV2Pair && balanceOf(uniswapV2Pair) > 0) { SellHistories memory sellHistory; sellHistory.time = block.timestamp; sellHistory.bnbAmount = _getSellBnBAmount(amount); _sellHistories.push(sellHistory); }||


###### Status: Closed The team has set _isAutoBuyBack to false, which means the _removeOldSellHistories() function is never called. Note: This setting can be changed again by the owner at any point of time in the future. Comments from Auditee: “We have disabled _isAutoBuyBack to avoid the _sellHistories array size issue.”

 3. AutoBoost feature can be exploited

 Line Code

 691-697 if (to == uniswapV2Pair && balanceOf(uniswapV2Pair) > 0) {   SellHistories memory sellHistory;   sellHistory.time = block.timestamp;   sellHistory.bnbAmount = _getSellBnBAmount(amount);
   _sellHistories.push(sellHistory); }

 Description A sell transaction or the swap from MiniDOGE to ETH will have to == uniswapV2Pair . But any user can exploit this by sending normal transactions to uniswapV2Pair address. This will fill the _sellHistories[] array with incorrect entries. Any user can send in very small amounts of tokens to fill up the _sellHistories[] array, for _buyBackTimeInterval minutes. And when the _isAutoBuyBack == true , _bBSLimitMax will be the average of transactions in the last _buyBackTimeInterval minutes. And due to this, the tokens bought back with the buyBackTokens() function will be less. This can lead to token price manipulation.
 Remediation We recommend changing the logic used to determine a token sale.  In the _bBSLimitMax calculation, taking the average of the last few transactions can be used by a malicious user to manipulate the token price.

 Status: Acknowledged by the Auditee Comments from Auditee: “We understand the risks of this possible exploitation and are monitoring specifically for it.”

 0507


-----

|Line|Code|
|---|---|
|572-575 function transfer(address recipient, uint256 amount) public override returns (bool) { _transfer(_msgSender(), recipient, amount); return true; }||
|586-590 function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) { _transfer(sender, recipient, amount); _approve(sender, _msgSender(), _allowances[sender] [_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")); return true; }||


###### 4. Missing Check for Reentrancy Attack.

 Line Code

 572-575   function transfer(address recipient, uint256 amount) public override
 returns (bool) {     _transfer(_msgSender(), recipient, amount);     return true;   }

 586-590   function transferFrom(address sender, address recipient, uint256
 amount) public override returns (bool) {     _transfer(sender, recipient, amount);     _approve(sender, _msgSender(), _allowances[sender]
 [_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));     return true;   }

 Description Calling MiniDOGE.transfer() and MiniDOGE.transferFrom() might trigger function uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTo kens() and uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTo kens() , which is implemented by a third party at uniswapV2Router. If there are vulnerable external calls in uniswapV2Router, reentrancy attacks could be conducted because these two functions have state updates and event emits after external calls.
 The scope of the audit would treat the third-party implementation at uniswapV2Router as a black box and assume its functional correctness. However, third parties may be compromised in the real world that leads to assets lost or stolen.
 Remediation We recommend applying OpenZeppelin ReentrancyGuard library - nonReentrant modifier for the aforementioned functions to prevent reentrancy attacks.

 Status: Acknowledged by the Auditee

 0508


-----

###### 5. Centralization Risks

 Description The role owner has the authority to    update settings (transaction fees and addresses)   manage the list containing contracts excluding from reward, fee, or    max transaction limitation.   withdraw ether from the contract at any point of time.
 Remediation We advise the client to handle the governance account carefully to avoid any potential hack. We also advise the client to consider the following solutions:
   with reasonable latency for community awareness on privileged    operations;    Multisig with community-voted 3rd-party independent co-signers;   DAO or Governance module increasing transparency and community    involvement;

 Status: Acknowledged by the Auditee Comments from Auditee: “We are working on a governance platform to allow the community to have a voice in these types of decisions. We will also look at a multiSig wallet to ensure these settings are not erroneously used by any person.”

 0509


-----

|Line|Code|
|---|---|
|1112-1114 function setMarketingAddress(address _marketingAddress) external onlyOwner { marketingAddress = payable(_marketingAddress); }||


