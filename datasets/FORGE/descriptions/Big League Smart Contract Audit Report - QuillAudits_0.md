#### High severity issues

###### 1. Backdoor in transferFrom function
 Line No: 131

 Description If a user gives an allowance of the maximum value of uint256, the spender can spend an infinite amount of tokens on the user's behalf. Allowance won’t change on transfer as it should.

 Remediation Allowance should be deducted on each successful transferFrom; there should be no conditions regarding deduction. If a transfer is successful, the allowance should decrease respectively.

 Status: Open

 2. Possible denial of service for transfer functionality 
 Line No: 167

 05


-----

###### Description Anyone can add more ether to the contract; if there is a disparity between ether and tokens when adding ether liquidity, it can result in reverting of tx. And all successive transfers will revert until enough tokens/ether are not added to the contract.

 Remediation Ensure token, and ether amount are synchronized before adding liquidity. A better approach would be to ask for a quote from DEX and manage tokens and ether accordingly.

 Status: Open

 3. Using the approve function of the token standard

 Description Proper events are not getting emitted for many of the critical operations; these are highly sensitive administrative operations as following -  - forbidMint
 - setFees
 - setHoldersWallet
 - setLiquidityThreshold
 - setRouter
 - setPair
 - _sellAndDistributeAccumulatedTKNFee

 Events are necessary for tracking changes on blockchain as tracking each transaction is very tedious; events also help as notification in case of administrative compromise and planning mitigation of threat.

 Remediation Emit proper events for crucial operations.

 Status: Open

 0506


-----

