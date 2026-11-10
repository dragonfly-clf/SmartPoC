#### PPI - Potential Precision Issue


#### Description


A variable is being cast from a higher precision data type to a lower precision data type.


This can cause a loss of information and result in unexpected results. For example, if a


value of 300 is cast to a uint8, the resulting value will be truncated to 44 because uint8 can


only store values between 0 and 255. This can have unintended consequences if the


variable is used in subsequent calculations or comparisons.


The code statement


`uint144(myUSDBalance.mul(_amountIn).div(wbnbBalance))` might produce


precision issues.


#### Recommendation


It is recommend reviewing the code to identify any variables that are being cast to lower


precision data types. If possible, these variables should be modified to use higher precision


data types. Alternatively, if it is necessary to use lower precision data types, it is important


to carefully consider the implications of any casting operations and ensure that they do not


result in loss of precision.


-----

