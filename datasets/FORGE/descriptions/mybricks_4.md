#### DPI - Decimals Precision Inconsistency


#### Description


The decimals field of a contract's ERC20 token can be used to specify the number of


decimal places that the token uses. For example, if decimals is set to `8, it means that the`

smallest unit of the token is `0.00000001, and if decimals are set to` `18, it means that`


the smallest unit of the token is `0.000000000000000001 .`


However, there is an inconsistency in the way that the decimals field is handled in some


ERC20 contracts. The ERC20 specification does not specify how the decimals field should


be implemented, and as a result, some contracts use different precision numbers.


This inconsistency can cause problems when interacting with these contracts, as it is not


always clear how the decimals field should be interpreted. For example, if a contract


expects the decimals field to be 18 digits, but the contract being interacted with uses 8


digits, the result of the interaction may not be what was expected.


#### Recommendation


To avoid these issues, it is important to carefully review the implementation of the decimals

field of the underlying tokens. The team is advised to normalize each decimal to one single


source of truth. A recommended way is to scale all the decimals to the greatest token's


decimal. Hence, the contract will not lose precision in the calculations.


-----

The following example depicts 3 tokens with different decimals precision.


**ERC20** **Decimals**

Token 1 6

Token 2 9

Token 3 18


All the decimals could be normalized to 18 since it represents the ERC20 token with the


greatest digits.


-----

