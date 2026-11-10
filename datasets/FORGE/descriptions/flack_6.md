#### PLPI - Potential Liquidity Provision Inadequacy

**Criticality** Minor / Informative

**Location** Flack.sol#L397

**Status** Unresolved

#### Description

The contract operates under the assumption that liquidity is consistently provided to the

pair between the contract's token and the native currency. However, there is a possibility

that liquidity is provided to a different pair. This inadequacy in liquidity provision in the main

pair could expose the contract to risks. Specifically, during eligible transactions, where the

contract attempts to swap tokens with the main pair, a failure may occur if liquidity has

been added to a pair other than the primary one. Consequently, transactions triggering the

swap functionality will result in a revert.


-----

#### Recommendation

The team is advised to implement a runtime mechanism to check if the pair has adequate

liquidity provisions. This feature allows the contract to omit token swaps if the pair does not

have adequate liquidity provisions, significantly minimizing the risk of potential failures.

Furthermore, the team could ensure the contract has the capability to switch its active pair

in case liquidity is added to another pair.

Additionally, the contract could be designed to tolerate potential reverts from the swap

functionality, especially when it is a part of the main transfer flow. This can be achieved by

executing the contract's token swaps in a non-reversible manner, thereby ensuring a more

resilient and predictable operation.


-----

