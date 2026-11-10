#### FSA - Fixed Swap Address

**Criticality** minor

**Location** contract.sol#L506

##### Description

The swap address is assigned once in the constructor and it can not be changed.
The decentralized swaps sometimes create a new swap version or abandon the
current. A contract that cannot change the swap address may not be able to
catch-up the upgrade.

|Criticality|minor|
|---|---|
|Location|contract.sol#L506|


constructor (

address _dexRouter
) Auth(msg.sender) {

router = IDEXRouter(_dexRouter);
pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));


##### Recommendation

It could be better to allow the swap address mutation in case of future swap
updates.


-----

