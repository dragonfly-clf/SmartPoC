3. Frontrunning

 Upon deployment, the expected contract owner would have to call initialize( ) else the owner characteristics and privileges do not get set. This is an issue for two reasons:

 Scenario 1: Initialize is frontrun by a malicious actor If anyone asides from the intended owner calls initialize, they automatically become the owner of this PaymentVault contract with the privileges required to call withdraw on any of the deposited tokens. Bots could be listening on the network for scenarios set up just like this and take advantage of the exploit opportunity.
 Once the attacker is approved, they can set the owner to an auto-drain contract that immediately removes any deposits made into the vault. This could defeat the goal of having the contract act as a vault until needed.
 Scenario 2: Initialize does not get called by anyone This would make the owner variable set to address(0), and the withdraw function will be unusable since address(0) currently does not have a signer and cannot pass the onlyOwner check.

 Recommendation

 Ensure the deployer is aware of safe deployment practices. Also refer to OpenZeppelin’s guide linked here.

 Status

 Resolved

 Auditor’s Remark - The contract has been made non-upgradeable to mitigate the risk of frontrunning.


-----

###### Medium Severity Issues

 