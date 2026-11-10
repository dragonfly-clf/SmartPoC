2. Frontrunning

 Description

 Upon deployment, the expected contract owner would have to call initialize( ) else the owner characteristics and privileges do not get set. This is an issue for two reasons:
 Scenario 1: Initialize is frontrun by a malicious actor If anyone asides from the intended owner calls initialize, they automatically become the owner of the Advon contract with the privileges of the owner address. Bots could be listening on the network for scenarios set up just like this and take advantage of the exploit opportunity.
 Scenario 2: Initialize does not get called by anyone This would make the owner variable set to address(0), and core functionality will be unusable since address(0) currently does not have a signer and cannot pass the onlyOwner check.

 Remediation

 With the current contract structure, it is recommended to call the functions in this order to mitigate risk:  - deploy contract  - call initialize( )  - set wallets, release time, etc to ensure funds are sent to the right address and proper timing    follows.  - call distribute( )
 The contract deployer has to be aware of safe deployment practices, they can refer to OpenZeppelin’s guide linked: Writing Upgradeable Contracts - OpenZeppelin Docs.

 Status

 Partially Resolved

 Client’s Remarks: The contract when deployed via the proxy avoids this issue of frontrunning by a malicious actor.


-----

###### 