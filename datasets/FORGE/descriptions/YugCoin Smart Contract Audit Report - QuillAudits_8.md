9. Static variables can be set to constant

  string constant _name = "YUG";   string constant _symbol = "YUG";   uint8 constant _decimals = 18;

 Description

 The private variables (name, symbol and decimals) can save a little more gas at their declaration. If the total supply as well would be made static, it should be made constant too.

 Recommendation

 Consider making the variables constant.

 Status

 Resolved


-----

###### 