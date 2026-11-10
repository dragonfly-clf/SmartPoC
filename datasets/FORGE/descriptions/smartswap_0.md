#### PTAI - Potential Transfer Amount Inconsistency

**Criticality** Medium

**Location** DP2PToken.sol#L392,451

**Status** Unresolved

#### Description

The `transfer()` and `transferFrom()` functions are used to transfer a specified

amount of tokens to an address. The fee or tax is an amount that is charged to the sender

of an ERC20 token when tokens are transferred to another address. According to the

specification, the transferred amount could potentially be less than the expected amount.

This may produce inconsistency between the expected and the actual behavior.

The following example depicts the diversion between the expected and actual amount.

**Tax** **Amount** **Expected** **Actual**

No Tax 100 100 100

10% Tax 100 100 90

As a result, the contract considers that an amount of `deal.amount + deal.fee` of

the `deal.token` has been transferred to the contract, but the actual amount transferred

could be less.


-----

#### Recommendation

The team is advised to take into consideration the actual amount that has been transferred

instead of the expected.

It is important to note that an ERC20 transfer tax is not a standard feature of the ERC20

specification, and it is not universally implemented by all ERC20 contracts. Therefore, the

contract could produce the actual amount by calculating the difference between the

transfer call.
```
 Actual Transferred Amount = Balance After Transfer - Balance
Before Transfer

```

-----

