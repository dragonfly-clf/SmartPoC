## QSP-30 Rounding error

#### Severity: Undetermined

 Status: Fixed

###### File(s) affected: MStablePoolController.sol

 Description: In the function withdraw(), the amount of withdrawal credits is rounded up on L81. It seems that if all users would choose to redeem credits and some would get rounded-up, then the last user to withdraw would fail due to lack of credits.


###### Recommendation: Round down instead of rounding up. However, if this is indeed the correct logic, the following change could optimize L80-81 to "always round up": uint256 credits =
```
amount.mul(1e18).sub(1).div(exchangeRate).add(1);

 Update: The dev team has indicated that this is indeed the correct logic. The test 5_fund_user.js should demonstrate that this practice of rounding is not an issue. The following is an

```

###### explanation provided by the dev team about why these rounding operations work correctly: RariFundManager._withdrawFrom is configured not to withdraw more than the mUSD balance
 in mStable savings (i.e., the output mUSD amount of a withdrawal of all available credits), which is rounded down. Because this mUSD quantity is rounded down, when

```
MStableExchangeController.withdraw

```

###### is called, the conversion of this mUSD quantity back to credits could underestimate the credits necessary to output this amount by 1 (because


###### Solidity, by default, rounds the quotient of a division operation down). To avoid this, we round up the quantity of credits to withdraw so we make sure to withdraw at least the requested output

 mUSD amount. These calculations will never cause the quantity of credits to withdraw to exceed the available quantity.

