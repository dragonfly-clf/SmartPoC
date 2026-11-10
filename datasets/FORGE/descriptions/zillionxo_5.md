#### STC - Succeeded Transfer Check

**Criticality** minor / informative

**Location** contract.sol#L805

**Status** Unresolved

##### Description

According to the ERC20 specification, the transfer methods should be checked if
the result is successful. Otherwise, the contract may wrongly assume that the
transfer has been established.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L805|
|Status|Unresolved|


IERC20(_tokenAddr).transfer(_to, _amount);


##### Recommendation

The contract should check if the result of the transfer methods is successful.


-----

