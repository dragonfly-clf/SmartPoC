#### Commented Code exist

###### There are some instances of code being commented out in the following files that should be removed:


Line Comment

1246 // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not
exclude Uniswap router.');

##### Recommendation

###### Remove the commented code, or address them properly.


#### Audit Comments

##### 12. November 2021:

###### • There is still an owner (Owner still has not renounced ownership)

 • Developer can

 • set maxTxAmount to zero to lock transfer function

 • Set fees without any limitations

 • Excluded addresses cannot call deliver function


24

|Line|Comment|
|---|---|
|1246|// require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');|


##### Recommendation

###### Remove the commented code, or address them properly.


