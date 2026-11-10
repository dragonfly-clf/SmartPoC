#### PTRP - Potential Transfer Revert Propagation

|Criticality|Minor / Informative|
|---|---|
|Location|contracts/honeyether.sol#L2280,2288,2389|
|Status|Unresolved|


##### Description


The contract sends funds to a teamWallet as part of the transfer flow. This address
can either be a wallet address or a contract. If the address belongs to a contract
then it may revert from incoming payment. As a result, the error will propagate to the
token’s contract and revert the transfer.


##### Recommendation


The contract should tolerate the potential revert from the underlying contracts when
the interaction is part of the main transfer flow. This could be archived by not
allowing set contract addresses or by sending the funds in a non-revertable way.


-----

