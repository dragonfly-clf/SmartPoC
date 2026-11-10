### SFO - Sell Fee Oversight

**Criticality** Medium

**Location** TRITON.sol#L1475

**Status** Unresolved

### Description

The contract contains the `stakingEnabled` variable that, when enabled, does not

account for sell fees within the `else if (isSelling) condition . This oversight in`

the contract logic could lead to inconsistencies in fee application and enforcement,

particularly in scenarios involving selling transactions. The current implementation under the

`stakingEnabled` condition focuses on checking and resetting the staking status of

tokens, but it neglects the sets of sell fees, which are critical for maintaining the economic

balance and incentivization structure of the contract.


-----

### Recommendation

It is recommended to revise the contract logic to ensure that sell fees are appropriately

applied even when the `stakingEnabled` variable is active. This can be achieved by

setting the sell fee logic, regardless of the state of the `stakingEnabled` variable. By

doing so, the contract will consistently apply sell fees for all selling transactions, maintaining

the intended economic mechanisms and fee structures. This adjustment will enhance the

fairness and predictability of the contract's behavior, ensuring that all participants are

subject to the same fee rules irrespective of their staking status. Additionally, this change

will help prevent potential exploits or imbalances that could arise from the current oversight.


-----

