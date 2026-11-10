#### MVN - Μisleading Variables Naming

|Criticality|Minor / Informative|
|---|---|
|Location|GoldHunt.sol#L551|
|Status|Unresolved|


##### Description


Variables and functions can have misleading names if their names do not accurately
reflect the value they contain or the purpose they serve. The contract uses some
variable names that are too generic or do not clearly convey the information stored
in the variable. Misleading names can lead to confusion, making the code more
making the code more difficult to read and understand.

The rebase function is not fulfilling its intended purpose. Instead, it is adding new
tokens to the supply through a minting process.


##### Recommendation


It's always a good practice for the contract to contain names that are specific and
descriptive. The team is advised to keep in mind the readability of the code.


-----

