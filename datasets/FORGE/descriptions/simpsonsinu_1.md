#### CSD - Circulating Supply Discrepancy


#### Description


According to the ERC20 specification, the `totalSupply()` function should return the


total supply of the token. The total supply should always equal the sum of the balances. The


contract does not return the `totalSupply() . Instead, the function returns the`


`totalSupply()` minus the amount that has been moved to the dead address. This


amount is the circulating supply of the token. Many decentralized applications and tools are


calculating many indicators like the circulating supply and market cap based on the

```
totalSupply() . As a result, these applications will produce misleading results.

```

#### Recommendation


The `totalSupply()` should always equal the sum of the holder's balances. The


contract should comply with this convention so that the decentralized applications will


produce correct results.


-----

