3. Token allocation and transfers

 Description

 The ecosystemFund address is never set and if left unchecked would lead to loss of funds if the tokens (in the contract itself) are sent out to the ecosystemAddress which is the dead address perpetually. 50% of the supply is minted to the contract as well not sent to the respective addresses as well. A compromise of the contract will automatically put 50% of the total supply at risk. The dev also described eligibleWallets as those that do not need to go through the usual phase of locking and keeping tokens like normal accounts do. They could have the privilege of moving tokens without a fee or lockup period but they do not. The only privilege available to the eligibileWallets in the codebase is the ability to call transfer() and transferFrom() tokens before the saleEndTime. In the most recent inclusion, when transfers are made it first checks if the address is an eligible wallet, and also if it is an eligible reseller. If an address is an eligible reseller, it should not deduct any tokens to be locked when tokens pass through it. The flaw here is that the eligible reseller check the ‘to’ address and not the ‘owner’ address else it could have some tokens locked like every other non-privileged account. If the batch transfer function is called with an eligible reseller’s address as well, it would lead to same deduction for locked tokens which should not happen with privileged accounts.

  function transferFrom(address from, address to, uint256 amount) public ... {     if(eligibleWallets[owner]) {      if(eligibleResellers[owner]) { // should check ‘to’ not owner here        _transfer(owner,to,amount);       }  }   }

 Remediation

 Provide a setEcosystemAddress() function to update the ecosystem address as needed. Also, mint tokens to the already specified addresses to reduce the scale of risk in the event of a compromise. For eligible wallets, ensure the implementation matches the dev description of expected functionality. Ensure proper implementation for the eligible resellers checks in transfer, transferFrom, and batchTransfer. For batchTransfer, include checks for privileged accounts.

 Status

 Partially Resolved


-----

###### Medium Severity Issues

 