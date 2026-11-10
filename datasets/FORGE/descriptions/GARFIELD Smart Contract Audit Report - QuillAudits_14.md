12. Redundant Code

 Line Code

 1249 else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
 _transferStandard(sender, recipient, amount);     }

 723 uint256 bnbPool = currentBNBPool;

 Description When the contract enters the branch else if (!_isExcluded[sender] && ! _isExcluded[recipient]) or else, the contract will execute the same piece of code _transferStandard(sender, recipient, amount);

 The currentBNBPool can be used directly instead of having the bnbPool variable initialized.

 Remediation We recommend removing the following code:\

 else if (!_isExcluded[sender] && !_isExcluded[recipient]) { _transferStandard(sender, recipient, amount);     }

 And using the currentBNBPool instead of bnbPool.

 Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit 7ddb20dc1ff3084488832b68c31a8a86a966fae2

 0513


-----

###### 