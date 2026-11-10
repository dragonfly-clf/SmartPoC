#### Low Severity Issues

###### 3. Missing Address Validation

   function setStakingContract(address stakingContractAddress_) public onlyOwner {     stakingContractAddress = stakingContractAddress_;

   function allowBuyingBoosters(address bmonc) public returns (bool) {     boosterBuyingAllowed[msg.sender] = bmonc;     return true;   }

 0506


-----

######   function deliver(address user, uint256 numTokens) public {     require(msg.sender == stakingContractAddress, "Manual call not allowed");     balances[user] = balances[user].add(numTokens);     _totalSupply = _totalSupply.add(numTokens);     emit Transfer(address(0), user, numTokens);   }

 Description Certain functions lack a safety check in the address; the address-type argument should include a zero-address test; otherwise, the contract's functionality may become inaccessible, or tokens may be burned in perpetuity.
 Remediation It’s recommended to undertake further validation prior to user-supplied data. The concerns can be resolved by utilizing a whitelist technique or a modifier.

 Status: Acknowledged by the Auditee

 4. Lack of MultiSig Transactions

   function setStakingContract(address stakingContractAddress_) public onlyOwner {     stakingContractAddress = stakingContractAddress_;   }

 Description In the Binamon Energy Contract, QuillAudits team, noticed that the staking contract address can be changed by calling the setStakingContract and the staking contract has the privilege to call the deliver function which can send an infinite number of tokens to users. These situations are often enabled because a single executor role has access to these functions. While sometimes, the developer or owner does not intend to do this malicious act, this risk still exists if the private key stolen since there is nothing preventing the key-holder from calling the setStakingContract.
 Remediation This function will allow the owner to mint an infinite number of tokens; Binamon Team does only uses the onlyOwner modifier to perform critical actions of the tokens. However, these functionalities should be split between multiple based users with multi-signatures wallet for each one.

 Status: Acknowledged by the Auditee

 0507


-----

###### 5. Usage of BlockimeStamp.

     require(amount <= maxRestrictionAmount, "BNRG: amount greater than max limit in restricted mode");       require(lastTx[sender].add(60) <= block.timestamp && lastTx[recipient].add(60) <= block.timestamp, "BMON: only one tx/min in restricted mode");       lastTx[sender] = block.timestamp;       lastTx[recipient] = block.timestamp;     }     if (state == State.Unlocked) {       if (isBlacklisted[recipient]) {         require(lastTx[recipient] + 30 days <= block.timestamp, "BNRG: only one tx/ month in banned mode");         lastTx[recipient] = block.timestamp;       } else if (isBlacklisted[sender]) {         require(lastTx[sender] + 30 days <= block.timestamp, "BNRG: only one tx/ month in banned mode");         lastTx[sender] = block.timestamp;       }

 Description Block.timestamp is used in the contract. The variable block is a set of variables. The timestamp does not always reflect the current time and may be inaccurate. The value of a block can be influenced by miners. Maximal Extractable Value attacks require a timestamp of up to 900 seconds. There is no guarantee that the value is right; all that is guaranteed is that it is higher than the timestamp of the previous block.

 Remediation You can use an Oracle to get the exact time or verify if a delay of 900 seconds won’t destroy the logic of the staking contract.

 Status: Acknowledged by the Auditee

