#### MSC - Missing Sanity Check


#### Description


The contract is processing variables that have not been properly sanitized and checked that


they form the proper shape. These variables may produce vulnerability issues.


The variables `_myUSD,` `_wbnb` and, `_pair` could be set to wallet address.


-----

The variable `nftPrice` could be set to zero, and as a result, the allocated funds will not


be distributed as expected.


#### Recommendation


The team is advised to properly check the variables according to the required


specifications.



- The variables `_myUSD,` `_wbnb` and, `_pair` should be contract addressed.

- The variable `nftPrice` should be greater than zero.

- Percentage nominators should never exceed percentage denominators.


-----

