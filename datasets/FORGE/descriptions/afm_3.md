#### MMF - Misleading Multisign Functionality

|Criticality|Minor / Informative|
|---|---|
|Location|AFM.sol#L892|
|Status|Unresolved|


##### Description


The contract is using a method for securing the mutate operations, this method is
called multi-signature. Intuitively the multi-signature means that the change should
be approved from many wallets. On the contrary, the implementation required
always two wallets to approve the operation. As a result, it is a double-signature
rather than multi-signature functionality.


##### Recommendation


The team is advised to rename the multi-signature methods to something closer to
the actual functionality. For instance, double-signature.


-----

