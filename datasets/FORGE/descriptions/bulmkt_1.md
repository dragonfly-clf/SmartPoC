#### IVU - Inefficient Variable Usage

**Criticality** Minor / Informative

**Location** BullMeerkatToken.sol#L750,795

**Status** Unresolved

#### Description

The contract is designed to use two separate variables, `maxTxAmount` and
```
maxWalletBalance, to control transaction limits within its ecosystem. Both of these

```
variables are set to 1% of the total supply. The `maxTxAmount` restricts the amount

transferred in each transaction, while the `maxWalletBalance` limits the maximum

balance a recipient can hold. However, both variables are set to the same value, making

one of the conditions redundant. In the current setup, if a transaction passes the

`maxTxAmount` check, it will invariably pass the `maxWalletBalance` check as well,

rendering the latter check unnecessary. This redundancy not only adds unnecessary

complexity to the contract but also consumes additional gas, which could be optimized for

better contract efficiency.


-----

#### Recommendation

It is recommended to streamline the contract by removing the redundant variable and

check. Since both `maxTxAmount` and `maxWalletBalance` are equal, ensuring

compliance with the `maxWalletBalance` condition inherently guarantees compliance

with the `maxTxAmount` condition. Therefore, the `maxTxAmount` check can be safely

removed from the `checkTxLimit` function. This simplification will reduce the contract's

complexity and gas consumption, leading to a more efficient and cost-effective

implementation. This will optimize and enhance the overall contract performance.


-----

