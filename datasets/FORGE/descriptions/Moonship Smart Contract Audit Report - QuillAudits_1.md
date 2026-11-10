#### Medium severity issues

###### 2. Missing Check for Reentrancy Attack

 Line Code

 995 function transfer(address recipient, uint256 amount) public override
 returns (bool) {     _transfer(_msgSender(), recipient, amount, 0);     return true;   }

 1009 function transferFrom(address sender, address recipient, uint256 amount)
 public override returns (bool) {     _transfer(sender, recipient, amount, 0);     _approve(sender, _msgSender(), _allowances[sender]
 [_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));     return true;   }

 Description: Calling moonship.transfer() and moonship.transferFrom() might trigger function nutRouter.swapExactTokensForETHSupportingFeeOnTransfer Tokens() and nutRouter.addLiquidityETH() , which is implemented by third party at InutRouter02 , in Utils.swapTokensForEth() and Utils.addLiquidity(). If there are vulnerable external calls in InutRouter02 , reentrancy attacks could be conducted because these two functions have state updates and event emits after external calls.
 The scope of the audit would treat the third-party implementation at InutRouter02 as a black box and assume its functional correctness. However, third parties may be compromised in the real world that leads to assets lost or stolen.
 Remediation: We recommend applying OpenZeppelin ReentrancyGuard library - nonReentrant modifier for the aforementioned functions to prevent

 Status: Acknowledged by the Auditee

 0506


-----

|Line|Code|
|---|---|
|1307|function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner() { _maxTxAmount = _tTotal.mul(maxTxPercent).div(10000); }|


###### 3. Centralization Risks

 Description: The role owner has the authority to    update settings    manage the list containing contracts excluding from reward, fee, or    max transaction limitation
 Remediation: We advise the client to handle the governance account carefully to avoid any potential hack. We also advise the client to consider the following solutions:   With reasonable latency for community awareness on privileged   operations;    Multisig with community-voted 3rd-party independent co-signers;   DAO or Governance module increasing transparency and community   involvement;   Setting _isExcludedFromMaxTx[owner()] = False

 Status: Acknowledged by the Auditee

 4.Inappropriate Variable Initialization

 Line Code

 1307 function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner() {     _maxTxAmount = _tTotal.mul(maxTxPercent).div(10000);   }

 Description: _maxTxAmount should be 0.05% of the total supply according to the code comment. But the _maxTxPercent can be set by the owner by calling setMaxTxPercent function at line 1307
 Remediation: We recommend setting the _maxTxPercent as a constant value which is calculated by 5% of the _tTotal

 Status: Acknowledged by the Auditee

 0507


-----

|Line|Code|
|---|---|
|1340|require(balanceOf(msg.sender) >= 0, 'Error: must own MRAT to claim reward');|

|Line|Code|
|---|---|
|1245|else if (!_isExcluded[sender] && !_isExcluded[recipient])|


