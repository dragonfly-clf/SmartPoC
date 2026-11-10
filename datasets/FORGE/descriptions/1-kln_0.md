#### MT - Mint Tokens

**Criticality** critical

**Location** contract.sol#L934,977

**Status** Renounced Ownership

##### Description

The contract owner has the authority to mint tokens. The owner may take
advantage of it by calling the mint function. As a result the contract tokens will be
highly inflated.

|Criticality|critical|
|---|---|
|Location|contract.sol#L934,977|
|Status|Renounced Ownership|

```
function mint(address to, uint256 amount) public onlyOwner {
  _mint(to, amount);
}

```

The signerAddress that is defined by the contract owner has the authority to mint
tokens. The signerAddress may take advantage of it by calling the claim function
with the appropriate signature. As a result the contract tokens will be highly inflated.

```
function claim(bytes memory params) public {
  require(claimState, "unable to claim now");
  claimInternal(claimDecodeParams(params));
}
function claimInternal(claimParams memory store) private {
  require(store.user == _msgSender(), "Invalid user");
  require(block.timestamp < store.deadline, "Time Expired");
  require(!signStatus[store.signature], "already sign used");
  bytes32 hash_ = keccak256(abi.encodePacked(
    SIGNATURE_PERMIT_TYPEHASH,
    address(this),
    store.user,
    store.amount,
    store.slot,
    store.deadline
  ));
  require(signCheck(ECDSA.toEthSignedMessageHash(hash_),store.signature),

```

-----

```
"Sign Error");
  signStatus[store.signature] = true;
  _mint(store.user,store.amount);
  emit claimEvent(store.user,store.amount,block.timestamp);
}

```

##### Recommendation

The owner should carefully manage the credentials of the owner’s account. We
advised considering an extra-strong security mechanism that the actions may be
quarantined by many users instead of one. The owner could also renounce the
contract ownership for a period of time or pass the access to the zero address.

##### Team Update 8th May 2022

The contract ownership has been renouned. The claimState has been configured to
false before the renounce. Hence, the contract cannot be manipulated by the
contract owner.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|


-----

