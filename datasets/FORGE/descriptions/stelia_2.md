#### BLC - Business Logic Concern

**Criticality** minor

**Location** contract.sol#L804

##### Description

The business logic seems peculiar. The implementation may not follow the expected
behavior. In both iterations the owner is able to enable the antibotModeWhitelist
addresses.

|Criticality|minor|
|---|---|
|Location|contract.sol#L804|

```
function setAntibotModeWhitelist(address[] memory toAddAddesses, address[]
memory toRemoveAddesses) public onlyOwner {
    for (uint256 i = 0; i < toAddAddesses.length; i++)
antibotModeWhitelist[toAddAddesses[i]] = true;
    for (uint256 i = 0; i < toRemoveAddesses.length; i++)
antibotModeWhitelist[toRemoveAddesses[i]] = true;
  }

```

##### Recommendation

The team is advised to carefully check if the implementation follows the expected
business logic.


-----

