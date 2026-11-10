#### MT - Mint Tokens

**Criticality** critical

**Location** contract.sol#L1229

##### Description

The contract owner has the authority to mint tokens. The owner may take
advantage of it by calling the mint function. As a result the contract tokens will be
highly inflated.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1229|

```
function mint(address account_, uint256 amount_) external onlyVault() {
   if(msg.sender == _vault)
   _mint(account_, amount_);
 }

```

##### Recommendation

The owner should carefully manage the credentials of the owner’s account. We
advised considering an extra-strong security mechanism that the actions may be
quarantined by many users instead of one. The owner could also renounce the
contract ownership for a period of time or pass the access to the zero address.


-----

