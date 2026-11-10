#### MAL - Misused Algorithmic Logic


#### Description


The algorithmic flow does not follow the required business logic.


The contract checks if the transaction is a sale and adds the fees to the `sellAmount`


variable, else it adds the fees to the `buyAmount` variable. The else block contains


transactions that are not buys, such as simple transfers. As a result, the `buyAmount` will


have a misleading value.


#### Recommendation


The code segment should be reshaped to match the business logic.


-----

