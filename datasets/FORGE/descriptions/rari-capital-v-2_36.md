## QSP-37 Privileged Roles and Ownership

#### Severity: Informational

 Status: Fixed

###### File(s) affected: RariFundController.sol

 Description: Smart contracts will often have owner variables to designate the person with special privileges to make modifications to the smart contract. In particular:

#### 1. In RariFundController.sol, the owner can invoke setEnzymeComptroller at any point.

 2. In RariGovernanceTokenUniswapDistributor.sol, if the owner changes the Uniswap pair address using setRgtEthUniswapV2Pair, users that have already
 deposited may not be able to withdraw.

###### Recommendation: This centralization of power needs to be made clear to the users, especially depending on the level of privilege the contract allows to the owner. Consider disallowing changes


-----

###### to rgtEthUniswapV2Pair after it has already been set.
 Update from the Rari Capital team: We have made this clear in the "Security" section of CONCEPT.md in all repositories. We have also added a check in

```
RariGovernanceTokenUniswapDistributor.setRgtEthUniswapV2Pair

