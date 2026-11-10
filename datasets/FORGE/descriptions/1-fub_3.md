#### BLC - Business Logic Concern

**Criticality** medium

**Location** contract.sol#L2192

**Status** Resolved

###### Description

The business logic seems peculiar. The implementation may not follow the expected
behaviour.

|Criticality|medium|
|---|---|
|Location|contract.sol#L2192|
|Status|Resolved|


function setDeadWallet(address addr) public onlyOwner {

deadWallet = addr;
}


###### Recommendation

Dead wallet should not be able to change, it may mislead the meaning of burn fee.

The team is advised to carefully check if the implementation follows the expected
business logic.

###### Updated 04 August 2022

The team has renounced ownership and resolved the issues.


-----

