11. Tautology or Contradiction Issue

 Line Code

 1340 require(balanceOf(msg.sender) >= 0, 'Error: must own MRAT to claim reward');

 Description balanceOf(msg.sender) >= 0 is true even if the balance of the msg.sender is 0. This comparison is a tautology that will waste gas during the execution

 Remediation Fix the incorrect comparison by changing the value type or the comparison.

 0512


-----

|Line|Code|
|---|---|
|1249 else if (!_isExcluded[sender] && !_isExcluded[recipient]) { _transferStandard(sender, recipient, amount); }||
|723 uint256 bnbPool = currentBNBPool;||


###### Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit 7bfdc0fc6ff8f4027d6fc83c4682d0107b46d302

 