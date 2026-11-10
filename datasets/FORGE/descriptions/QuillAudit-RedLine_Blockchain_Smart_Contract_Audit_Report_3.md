Informational issues

 3. Total Supply

 The standard is to show the total tokens in circulation when it comes to totalSupply. Even then, if you decide to keep it this way(as shown below) please use safeSub to keep uniformity throughout the code.  Although, after putting in a check for the zero address as suggested above we can remove balances[address(0)] altogether on line 60. 

 Status: Acknowledged

 4. Indentation

 Please follow the solidity style guide for better code readability. You can read more about it here.

 Status: Acknowledged

 5. Require messages

 Consider adding error messages inside the require statements which will make debugging failed transactions much easier. You can read more about error handling here. 

 Status: Acknowledged

 audits.quillhash.com 06