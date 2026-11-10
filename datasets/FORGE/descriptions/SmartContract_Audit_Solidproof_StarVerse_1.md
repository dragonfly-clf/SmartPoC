#### Informational issues


21


-----

|#1|Main|State variables that could be declared constant (constable- states)|434, 436, 424, 435, 417, 405, 445, 403, 419, 404, 399, 388, 426, 429|Add the `constant` attributes to state variables that never change|
|---|---|---|---|---|



###### • When it’s disabled you are not allowed to swap tokens or use buy back functions

 • set buy back sell amount to zero

If condition in _transfer function

_buyBackDivisor > 0 is useless because there is no setter function to set that
variable
_buyBackDivisor is 10 by default

######  


#### Audit Comments

##### 14. September 2021:

###### There is still an owner (Owner still has not renounced ownership)
 Developer can

 • Set auto buy back

 • set maxTxAmount to zero to lock transfer function

 • set buy back upper limit

 • Enable/disable buy back

 • When it’s disabled you are not allowed to swap ETH for tokens

 • Enable/disable swap and liquify

 • When it’s disabled you are not allowed to swap tokens or use buy back functions

 • set buy back sell amount to zero

If condition in _transfer function

_buyBackDivisor > 0 is useless because there is no setter function to set that
variable
_buyBackDivisor is 10 by default


22


-----

