State Variables Should be Declared Constant (3 Items)
Following state variables in this contract should be declared as constant.

```
|Function|Severity|Relevant Snippet|
|---|---|---|
|SlappyCat._decimals (SlappyCat.sol#354) should be constant|Severity : High|uint8 private _decimals = 9;|
|SlappyCat._name (SlappyCat.sol#352) should be constant|Severity : High|string private _name = "Slappy Cat Coin";|
|SlappyCat._symbol (SlappyCat.sol#353) should be constant|Severity : High|string private _symbol = "SLAPPYCAT";|


-----

```
 