2. activateContract() function can be called many times

 Description This function is created to activate the contract after deployment. However, the activateContract() function can reset all the critical settings of the contract and is called many times by the owner.

 This indicates that the malicious owner either has control over the function or accidentally calls it. As a result, all settings will be reset, and the contract may be put at risk.

 Remediation We recommend putting all the settings into separate functions where it can be called by the owner or initializing it in the constructor. Otherwise, the Auditee should be aware of the aforementioned risks.

 Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit 61a51d3b7753c86511d0963b78ac3cd5da72011a

 