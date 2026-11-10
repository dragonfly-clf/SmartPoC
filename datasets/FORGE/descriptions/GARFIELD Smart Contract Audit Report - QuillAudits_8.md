7. Inappropriate Variable Initialization

 Line Code

 1311 function setMaxTxPercent(uint256 maxTxPercent) public onlyOwner() {     _maxTxAmount = _tTotal.mul(maxTxPercent).div(10000);   }

 0509


-----

###### Description _maxTxAmount should be 0.05% of the total supply according to the code comment.

 But the _maxTxPercent can be set by the owner by calling setMaxTxPercent function at line 1311

 Remediation We recommend setting the _maxTxPercent as a constant value or consider changing the business logic mentioned in the code comment.

 Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit 0f86a14e594a2dc2e54ad7be71b11e46fdf6fd04. Nevertheless, the better way is to make the variable constant.

 