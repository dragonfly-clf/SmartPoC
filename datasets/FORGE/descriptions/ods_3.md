#### ZD - Zero Division


#### Description


The contract is using variables that may be set to zero as denominators. This can lead to


unpredictable and potentially harmful results, such as a transaction revert.


If the variable `swapTokensAtAmount` is set to zero, then the variables `buyAmount`


and `sellAmount` will may not have accumulated fees before the contract enters the


swapping stage and their value will be zero. As a result, the contract will execute a division


by zero causing the transaction to revert.


#### Recommendation


It is important to handle division by zero appropriately in the code to avoid unintended


behavior and to ensure the reliability and safety of the contract. The contract should ensure

that the divisor is always non-zero before performing a division operation. It should prevent


the variables to be set to zero, or should not allow the execution of the corresponding


statements.


-----

