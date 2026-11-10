#### OTUT - Owner Transfer User's Tokens

**Criticality** critical

**Location** contract.sol#L492

##### Description

The contract owner has the authority to transfer the balance of a user’s contract to
the owner’s contract. The owner may take advantage of it by calling the
```
multiTransfer function.

```
|Criticality|critical|
|---|---|
|Location|contract.sol#L492|

```
function multiTransfer(address from, address[] calldata addresses, uint256[]
calldata tokens) external onlyOwner {
  require(launchMode,"Cannot execute this after launch is done");
  require(addresses.length < 501,"GAS Error: max airdrop limit is 500
addresses");
  require(addresses.length == tokens.length,"Mismatch between Address and
token count");
  uint256 SCCC = 0;
  for(uint i=0; i < addresses.length; i++){
    SCCC = SCCC + tokens[i];
  }
  require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");
  for(uint i=0; i < addresses.length; i++){
    _basicTransfer(from,addresses[i],tokens[i]);
  }}

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract, renouncing ownership or calling ​the
tradingStatus_launchmode function.


-----

