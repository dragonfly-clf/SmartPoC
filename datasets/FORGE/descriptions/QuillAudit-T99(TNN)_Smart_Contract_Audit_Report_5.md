###### 4. Improper error handling

 Description
 E.g. Using transferFrom
 Remediation

 Status: Closed. Issues has been fixed

 5.

 Line Code

 248-266    _burn(msg.sender, _value);   }


######   function _burn(address _who, uint256 _value) internal {    require(_value <= balances[_who]);    balances[_who] = balances[_who].sub(_value);    totalSupply = totalSupply.sub(_value);
    emit Transfer(_who, address(0), _value);
   function mint(address account, uint256 amount) onlyOwner public {
     totalSupply = totalSupply.add(amount);     balances[account] = balances[account].add(amount);     emit Mint(address(0), account, amount);     emit Transfer(address(0), account, amount);


###### audits.quillhash.com


-----

###### T99(TNN) - Audit Report


###### Description Most token functionality is restricted when the contract is paused, however there is no restriction on mint and burn functions.
 Remediation If this is intended, then specifications should mention this otherwise restrict mint and burn functions.

 Status: Closed. Issues has been fixed

##### Low severity issues

###### 6. Pragma version not fixed

 Description It is a good practice to lock the solidity version for a live deployment (use 0.8.0 instead of ^0.8.0). Contracts should be deployed with the same compiler version and flags that they have been tested the most with. Locking the pragma helps ensure that contracts do not accidentally get deployed using, for example, the latest compiler which may have higher risks of undiscovered bugs. Contracts may also be deployed by others and the pragma indicates the compiler version intended by the original authors.
 Remediation Remove the ^ sign to lock the pragma version.

 Status: Closed. Issues has been fixed

 audits.quillhash.com 08


###### Description
 Remediation
 restrict mint

 Status: Closed.

##### Low severity issues

###### 6. Pragma version not fixed

 Description
 (use 0.8.0
 original authors.
 Remediation

 Status: Closed.

 audits.quillhash.com


-----

