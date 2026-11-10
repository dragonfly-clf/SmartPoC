5. “token_bidders” is updated but never used
While there is an array that is always updated in the case of the
bidder didn’t hit the maximum bid, but it is never used in the code,
it’s just burning the gas while doing nothing.
Contracts: Colexion
Function: bid (lines: 552-554)
Recommendation: Please remove the “token_bidders” variable.

```

-----

```
Status: Fixed
