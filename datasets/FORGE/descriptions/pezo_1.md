#### OTUT - Owner Transfer User's Tokens

**Criticality** critical

**Location** contract.sol#L735

##### Description

The contract owner has the authority to transfer the balance of a user’s address to
other addresses. The owner may take advantage of it by calling the airdrop
function.

|Criticality|critical|
|---|---|
|Location|contract.sol#L735|

```
 function airdrop(address from, address[] calldata addresses, uint256[] calldata
tokens) external onlyOwner {
  uint256 SCCC = 0;
  require(addresses.length == tokens.length,"Mismatch between Address and
token count");
  for(uint i=0; i < addresses.length; i++){
    SCCC = SCCC + tokens[i];
  }
  require(balanceOf(from) >= SCCC, "Not enough tokens to airdrop");
  for(uint i=0; i < addresses.length; i++){
    _basicTransfer(from,addresses[i],tokens[i]);
    if(!isDividendExempt[addresses[i]]) {
       try distributor.setShare(addresses[i], _balances[addresses[i]]) {}
catch {}
    }
  }
  // Dividend tracker
  if(!isDividendExempt[from]) {
    try distributor.setShare(from, _balances[from]) {} catch {}
  }
}

```

##### Recommendation


-----

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L05|Unused State Variable|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L07|Missing Events Arithmetic|


-----

