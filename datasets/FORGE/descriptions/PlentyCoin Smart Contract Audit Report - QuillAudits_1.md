#### Medium severity issues

###### 3. Centralized risk in addLiquidity

 Description The role owner has the authority to    update settings (transaction fees and addresses)   manage the list containing contracts excluding from reward, fee, or    max transaction limitation.   withdraw ether from the contract at any point of time.   unlock tokens for any user

 0507


-----

|Line|Code|
|---|---|
|1926-1948 function transferFromWithLock( address _from, address _to, bytes32 _reason, uint256 _amount, uint256 _time ) public returns (bool) { uint256 validUntil = block.timestamp.add(_time); require(isWhitelistAdmin(_from), "ERC1132: Not whitelisted"); require(tokensLocked(_to, _reason) == 0, "ERC1132: Already locked"); require(_amount != 0, "ERC1132: Zero Amount"); if (locked[_to][_reason].amount == 0) lockReason[_to].push(_reason); transferFrom(_from, address(this), _amount); locked[_to][_reason] = LockToken(_amount, validUntil, false); _lockedAmount.add(_amount); emit Locked(_to, _reason, _amount, validUntil); return true; }||


###### Remediation . We advise the client to handle the governance account carefully to avoid any potential hack. We also advise the client to consider the following solutions:
   with reasonable latency for community awareness on privileged    operations;    Multisig with community-voted 3rd-party independent co-signers;   DAO or Governance module increasing transparency and community    involvement;

 Status: Acknowledged by the Auditee Comments from Auditee: “We are composing the DAO structure so for now, it's actually centralized.”

