#### OTUT - Transfers User's Tokens

**Criticality** critical

**Location** contract.sol#L515

**Status** Unresolved

##### Description

Any user has the authority to transfer the balance of a user’s contract to other
addresses. The user may take advantage of it by calling the multiTransfer
function before the launchMode toggle to false.

|Criticality|critical|
|---|---|
|Location|contract.sol#L515|
|Status|Unresolved|

```
function multiTransfer(address from, address[] calldata addresses, uint256[]
calldata tokens) external authorized {
  if(msg.sender != from){
    require(launchMode,"Cannot execute this after launch is done");
  }
  require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
  require(addresses.length == tokens.length,"Mismatch between address and
token count");
  uint256 SCCC = 0;
  for(uint i=0; i < addresses.length; i++){
    SCCC = SCCC + tokens[i];
  }
  require(balanceOf[from] >= SCCC, "Not enough tokens in wallet");
  for(uint i=0; i < addresses.length; i++){
    1(from,addresses[i],tokens[i]);
  }
}

```

##### Recommendation

The contract should not allow arbitrary tokens transfers.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|ZD|Zero Division|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L13|Divide before Multiply Operation|Unresolved|


-----

