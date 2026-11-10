#### BLC - Business Logic Concern

**Criticality** minor

**Location** contract.sol#L155

##### Description

The business logic seems peculiar. The implementation may not follow the expected
behaviour.

The mapping _balances is set but never used. Instead the mapping _asdjiowf is
used.

|Criticality|minor|
|---|---|
|Location|contract.sol#L155|


mapping (address => uint256) _balances;mapping (address => uint256) _asdjiowf;


##### Recommendation

The team is advised to carefully check if the implementation follows the expected
business logic.


-----

