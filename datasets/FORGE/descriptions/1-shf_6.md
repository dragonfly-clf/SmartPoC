#### FSA - Fixed Swap Address

**Criticality** minor / informative

**Location** contract.sol#L206

**Status** Unresolved

##### Description

The swap address is assigned once in the constructor and it can not be changed.
The decentralized swaps sometimes create a new swap version or abandon the
current. A contract that cannot change the swap address may not be able to
catch-up the upgrade.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L206|
|Status|Unresolved|


constructor () Auth(msg.sender) {

router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
WBNB = router.WETH();

pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
_allowances[address(this)][address(router)] = type(uint256).max;


##### Recommendation

It could be better to allow the swap address mutation in case of future swap
updates.


-----

