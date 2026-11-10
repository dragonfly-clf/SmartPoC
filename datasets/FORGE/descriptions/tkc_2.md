#### ZD - Zero Division


#### Description


The contract is using variables that may be set to zero as denominators. This can lead to


unpredictable and potentially harmful results, such as a transaction revert.


The variable `totalFees` can be set to zero, and as a result, the transfer transaction will


revert.


#### Recommendation


It is important to handle division by zero appropriately in the code to avoid unintended


behavior and to ensure the reliability and safety of the contract. The contract should ensure

that the divisor is always non-zero before performing a division operation. It should prevent


the variables to be set to zero, or should not allow the execution of the corresponding


statements.


-----

