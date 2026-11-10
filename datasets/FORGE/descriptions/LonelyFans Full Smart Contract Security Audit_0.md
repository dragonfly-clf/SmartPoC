### High Severity Issues

###### 1. More tokens than 100% distributed

Issue:

There is a wrong tokens distribution in the constructor of the contract.
Total distributed tokens in the constructor will be the 100.5% from the
total supply! (1 + 1 + 0.5 * 8 + 5 + 89.5 = 100.5)

Recommendation:

Please recheck the logic of the tokens distribution. Also see the low
severity issue with wrong events!

