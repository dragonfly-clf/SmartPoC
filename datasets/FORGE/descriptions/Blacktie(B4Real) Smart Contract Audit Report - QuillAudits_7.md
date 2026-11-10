A.5 Transfer Ownership should be a two step process

 Function - transferOwnership()

 Description

 The transfer of ownership is crucial functionality in token contracts and it should be done by a two step process so that the owner doesn't mistakenly transfer ownership to a false address.

 Remediation

 Use a two way process so that the owner can verify the address once again after passing it in the function.

 Status

 Acknowledged