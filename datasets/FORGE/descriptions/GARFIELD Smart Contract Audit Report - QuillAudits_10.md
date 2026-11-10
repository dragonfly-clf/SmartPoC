9. A maximum value of GAR is allowed for the pancakeRouter

 Description A maximum value of GAR owned by the GARFIELD contract is allowed for the pancakeRouter in the activateContract() function.

 L1466: _approve(address(this), address(pancakeRouter), 2 ** 256 - 1);

 The scope of the audit would treat the third-party implementation at pancakeRouter as a black box and assume its functional correctness. However, third parties may be compromised in the real world that leads to assets being lost or stolen.

 0511


-----

|Line|Code|
|---|---|
|1340 require(balanceOf(msg.sender) >= 0, 'Error: must own MRAT to claim reward');||


###### Remediation The Auditee should be aware of the aforementioned risk and ensure that the pancakeRouter is a trusted party during the deployment.

 Status: Acknowledged by the Auditee

 