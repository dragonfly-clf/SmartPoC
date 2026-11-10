3. Public functions that could be declared external inorder to save gas

 Whenever a function is not called internally, it is recommended to define them as external instead of public in order to save gas. For all the public functions, the input parameters are copied to memory automatically, and it costs gas. If your function is only called externally, then you should explicitly mark it as external. External function’s parameters are not copied into memory but are read from calldata directly. This small optimization in your solidity code can save you a lot of gas when the function input parameters are huge. Here is a list of function that could be declared external:
  - totalSupply()  - name()  - symbol()  - decimals()    - increaseAllowance()  - decreaseAllowance()

 Status

 Fixed