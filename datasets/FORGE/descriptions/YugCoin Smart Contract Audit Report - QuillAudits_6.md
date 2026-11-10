7. Inaccurate error message

  function includeInReward(address account) public onlyOwner() {     require(_isExcluded[account], "Account is already excluded");

  function _mint(address account, uint256 amount) internal virtual {     require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

 Description

 The includeInReward function checks if the account address passed in is not already excluded. If (_isExcluded[account]) returns true, the program would run because the address checked is not excluded. If (_isExcluded[account]) returns false, the program should give an error that says “Account is not excluded” instead).
 Same with the error message in the _mint function.

 Recommendation

 Update the error message to give a more accurate response.

 Status

 Resolved


-----

###### 