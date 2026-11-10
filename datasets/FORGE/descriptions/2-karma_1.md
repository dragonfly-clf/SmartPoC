#### MC - Missing Check


#### Description


The contract is processing variables that have not been properly sanitized and checked that


they form the proper shape. These variables may produce vulnerability issues.


The variable `swapThreshold` sets a threshold where the contract will trigger the swap


functionality. If the swapThreshold is set to zero, the contract will perform redundant swaps.


#### Recommendation


The team is advised to properly check the variables according to the required


specifications.


#### Team Update


The contract's ownership has been renounced. The information regarding the transaction


can be accessed through the following link:


[https://bscscan.com/tx/0x5d7c25dffae6304ff73e00f334feb8d419f22b15a48a022f18d51a49](https://bscscan.com/tx/0x5d7c25dffae6304ff73e00f334feb8d419f22b15a48a022f18d51a490d13b04f)


[0d13b04f.](https://bscscan.com/tx/0x5d7c25dffae6304ff73e00f334feb8d419f22b15a48a022f18d51a490d13b04f)


-----

