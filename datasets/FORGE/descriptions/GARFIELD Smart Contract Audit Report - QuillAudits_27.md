24. Public function that could be declared external

 Description Using the external attribute for functions never called from the contract. Therefore, the following public functions that are never called by the contract should be declared external to save gas:   deliver()   excludeFromReward()   excludeFromFee()   includeInFee()   setExcludeFromMaxTx()   claimBNBReward()   disruptiveTransfer()   activateContract()

 0520


-----

|Line|Code|
|---|---|
|1309 uint256 minTokenNumberToSell||

|Line|Code|
|---|---|
|1342-1343 require(nextAvailableClaimDate[msg.sender] <= block.timestamp, 'Error: next available not reached'); require(balanceOf(msg.sender) >= 0, 'Error: must own MRAT to claim reward');||
|1362 require(sent, 'Error: Cannot withdraw reward');||


###### Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit 32b32117beb980ca3d3b4e2f813790b2c62eb47c

 