### TSD - Total Supply Diversion

**Criticality** Critical

**Location** TRITON.sol#L1561

**Status** Unresolved

### Description

The total supply of a token is the total number of tokens that have been created, while the

balances of individual accounts represent the number of tokens that an account owns. The

total supply and the balances of individual accounts are two separate concepts that are

managed by different variables in a smart contract. These two entities should be equal to

each other.

In the contract, the amount that is added to the total supply does not equal the amount that

is added to the balances. As a result, the sum of balances is diverse from the total supply.
```
 if (deadFees > 0) {
   burntokens = amount.mul(deadFees) / 100;
   super._transfer(from, DEAD, burntokens);
   _totalSupply = _totalSupply.sub(burntokens);
   }

### Recommendation

```
The total supply and the balance variables are separate and independent from each other.

The total supply represents the total number of tokens that have been created, while the

balance mapping stores the number of tokens that each account owns. The sum of

balances should always equal the total supply.


-----

