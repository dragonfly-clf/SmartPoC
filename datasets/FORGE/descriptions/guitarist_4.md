#### MC - Missing Check


#### Description


The contract is processing variables that have not been properly sanitized and checked that


they form the proper shape. These variables may produce vulnerability issues.


Specifically, the `setMax_per_wallet` function permits the owner to set the


`max_per_wallet` limit to a value higher than `MAX_SUPPLY, which could lead to`


inconsistencies and unintended behavior in the token distribution process.


#### Recommendation


The team is advised to properly check the variables according to the required


specifications. It is advised to modify the `setMax_per_wallet` function to include a


validation check that prevents setting the `max_per_wallet` limit above the

```
MAX_SUPPLY . These measures will ensure adherence to the intended supply constraints,

```

maintaining the integrity and rarity of the tokens as originally designed.


-----

