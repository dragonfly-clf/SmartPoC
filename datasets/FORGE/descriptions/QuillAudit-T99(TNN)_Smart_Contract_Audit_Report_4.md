###### 2. Token supply is not fixed

 Description
 behest of the token's owner.
 Remediation

 Status: Closed. Issues has been fixed

 3. The blacklistAddress function has been omitted

 Description
 still present but not used anywhere.
 Remediation
 call the internal _blacklist function.


###### audits.quillhash.com


-----

|Line|Code|
|---|---|
|248-266|function burn(uint256 _value) public { _burn(msg.sender, _value); } function _burn(address _who, uint256 _value) internal { require(_value <= balances[_who]); balances[_who] = balances[_who].sub(_value); totalSupply = totalSupply.sub(_value); emit Burn(_who, _value); emit Transfer(_who, address(0), _value); } function mint(address account, uint256 amount) onlyOwner public { totalSupply = totalSupply.add(amount); balances[account] = balances[account].add(amount); emit Mint(address(0), account, amount); emit Transfer(address(0), account, amount); }|


##### Medium severity issues

