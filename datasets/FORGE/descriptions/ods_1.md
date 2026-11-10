#### TSD - Total Supply Diversion


#### Description


The total supply of a token is the total number of tokens that have been created, while the


balances of individual accounts represent the number of tokens that an account owns. The


total supply and the balances of individual accounts are two separate concepts that are


managed by different variables in a smart contract. These two entities should be equal to


each other.


In the contract, the amount that is added to the total supply does not equal the amount that


is added to the balances. As a result, the sum of balances is diverse from the total supply.


#### Recommendation


The total supply and the balance variables are separate and independent from each other.


The total supply represents the total number of tokens that have been created, while the


balance mapping stores the number of tokens that each account owns. The sum of


balances should always equal the total supply.


-----

