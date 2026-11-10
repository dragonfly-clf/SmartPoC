#### RSK - Redundant Storage Keyword


#### Description


The contract uses the `storage` keyword in a view function. The `storage` keyword is


used to persist data on the contract's storage. View functions are functions that do not

modify the state of the contract and do not perform any actions that cost gas (such as


sending a transaction). As a result, the use of the `storage` keyword in view functions is


redundant.


#### Recommendation


It is generally considered good practice to avoid using the `storage` keyword in view


functions because it is unnecessary and can make the code less readable.


-----

