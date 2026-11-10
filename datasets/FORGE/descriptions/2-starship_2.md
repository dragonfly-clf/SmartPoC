#### MVN - Μisleading Variables Naming

|Criticality|Medium|
|---|---|
|Location|BABYTOKEN.sol#L2205|
|Status|Unresolved|


##### Description


Variables can have misleading names if their names do not accurately reflect the
value they contain or the purpose they serve. The contract uses some variable
names that are too generic or do not clearly convey the information stored in the
variable. Misleading variable names can lead to confusion, making the code more
difficult to read and understand.

The buyDeadFee, sellDeadFee and deadWallet intuitively means that the specific
tax is burned. On the contrary, the deadWallet address can be changed, as a result
the tokens will not be burned but moved to the specific address.


##### Recommendation


It's always a good practice for the contract to contain variable names that are
specific and descriptive. The team is advised to keep in mind the readability of the
code.


-----

