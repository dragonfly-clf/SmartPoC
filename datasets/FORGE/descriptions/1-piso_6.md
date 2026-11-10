#### STC - Succeeded Transfer Check

**Criticality** minor

**Location** contract.sol#L721

##### Description

According to the ERC20 specification, the transfer methods should be checked if
the result is successful. Otherwise, the contract may wrongly assume that the
transfer has been established.

|Criticality|minor|
|---|---|
|Location|contract.sol#L721|


function StopAirDrop(address _tokenAddr, address _to, uint _amount) public onlyOwner {

IERC20(_tokenAddr).transfer(_to, _amount);
}


##### Recommendation

The contract should check if the result of the transfer methods is successful.


-----

