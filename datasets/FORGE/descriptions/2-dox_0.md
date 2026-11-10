#### ST - Stops Transactions

**Criticality** Critical

**Location**

**Status** Unresolved

#### Description


The contract is currently designed in a way that allows the contract owner to exert


significant control over the sales process. Specifically, the owner has the capability to halt


all sales by either setting the total transaction fees to zero which results in the variable

```
totalBNBFee being zero, or by designating a contract address as the fee recipient, which

```

could revert to its receive function. This design introduces a critical vulnerability, as it can


effectively transform the contract into a honeypot. In such a scenario, users will be able to


deposit funds but will be unable to execute sales, leading to a situation where funds are


locked within the contract without the possibility of retrieval.


#### Recommendation

It is recommended to implement safeguards within the contract to mitigate this risk. The

ability to set a contract address as the fee recipient should be restricted. This can be

achieved by adding checks to ensure that the fee recipient is always an externally owned

account (EOA) and not a contract. Additionally, the possibility of setting the

`totalBNBFee` vairaible to zero should be handled appropriately.Moreover the team

should carefully manage the private keys of the owner’s account. We strongly recommend a


-----

powerful security mechanism that will prevent a single user from accessing the contract

admin functions.

Temporary Solutions:

These measurements do not decrease the severity of the finding

  - Introduce a multi-signature wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.

Permanent Solution:

  - Renouncing the ownership, which will eliminate the threats but it is non-reversible.


-----

