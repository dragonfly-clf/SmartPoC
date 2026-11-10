#### ΜDA - Μisleading Dead Address


#### Description


Variables can have misleading names if their names do not accurately reflect the value they


contain or the purpose they serve. The contract uses some variable names that are too


generic or do not clearly convey the information stored in the variable. Misleading variable


names can lead to confusion, making the code more difficult to read and understand.


The contract is using the `buyDeadFee` that intuitively should send the taxed amount to


the dead address. But, the `deadWallet` variable can be changed. As a result, the


`buyDeadFee` will not be used for a burning mechanism.


#### Recommendation


It's always a good practice for the contract to contain variable names that are specific and


descriptive. The team is advised to keep in mind the readability of the code. The DEAD


address should not be immutable.


-----

