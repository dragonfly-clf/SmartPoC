#### FRV - Fee Restoration Vulnerability

**Criticality** Medium

**Location** JIMBOY.sol#L281,291,410

**Status** Renounced

#### Description

The contract demonstrates a potential vulnerability upon removing and restoring the fees.

This vulnerability can occur when both `_taxFee` and `_redisFee` have been set to

zero. During a transaction, if the `takeFee` variable is false, then both `removeAllFee`

and `restoreAllFee` function will be executed. The `removeAllFee` function is

executed to temporarily remove the fees, ensuring the sender is not taxed during the

transfer. However, the function prematurely returns without setting the variables that hold

the previous fee values.

As a result, when the subsequent `restoreAllFee` function is called after the transfer, it

restores the fees to their previous values. However, since the previous fee values were not

properly set to zero, there is a risk that `_taxFee` and `_redisFee` will retain their

non-zero values from before the fees were removed. This can lead to unintended

consequences, potentially causing incorrect fee calculations or unexpected behavior within

the contract.


-----

#### Recommendation

The team is advised to modify the `removeAllFee` function to ensure that the previous

fee values are correctly set to zero, regardless of their initial values. A recommended

approach would be to remove the early return when both fees are zero.


-----

#### Team Update


Team Update The contract's ownership has been renounced. The information regarding the


transaction can be accessed through the following link:


[https://bscscan.com/tx/0xcc7516a17d7f5b99367b4a675a8666a3279a63133fd82c54b40a8](https://bscscan.com/tx/0xcc7516a17d7f5b99367b4a675a8666a3279a63133fd82c54b40a82d0ac33fb2d)


[2d0ac33fb2d.](https://bscscan.com/tx/0xcc7516a17d7f5b99367b4a675a8666a3279a63133fd82c54b40a82d0ac33fb2d)


-----

