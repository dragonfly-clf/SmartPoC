#### DDP - Decimal Division Precision

|Criticality|Medium|
|---|---|
|Location|contracts/honeyether.sol#L2284|
|Status|Unresolved|


##### Description


Division of decimal (fixed point) numbers can result in rounding errors due to the
way that division is implemented in Solidity. Thus, it may produce issues with
precise calculations with decimal numbers.

Solidity represents decimal numbers as integers, with the decimal point implied by
the number of decimal places specified in the type (e.g. decimal with 18 decimal
places). When a division is performed with decimal numbers, the result is also
represented as an integer, with the decimal point implied by the number of decimal
places in the type. This can lead to rounding errors, as the result may not be able to
be accurately represented as an integer with the specified number of decimal
places.

Hence, the splitted shares will not have the exact precision and some funds may not
be calculated as expected.


The feePercentages[i] wallet balance might produce issues with precision.


Additionally, the feePercentages size should be equal to the feeWallets size
otherwise the iteration will yield an out of bounds revert.


-----

##### Recommendation


The contract could calculate the subtraction of the divided funds in the last
calculation in order to avoid the division rounding issue. Additionally, the contract
should embody checks that guarantee the proper sizes for feeWallets.


-----

