#### Informational issues


23


-----

|#2|Main|Functions that are not used (dead-code)|MARSINU.a ddLiquidity( uint256,uint 256) (MarsInu.sol :740-753) is never used and should be removed|Remove unused functions|
|---|---|---|---|---|


#### Audit Comments

##### 02. November 2021:

###### • There is still an owner (Owner still has not renounced ownership)

 • Deployer can lock user funds

 • If sent amount is 0 and _maxTxAmount is set to 0

 • Addresses are not allowed to use transfer function anymore

 • The deployer can prevent the transfer by dividing the percentages (_liquidityFee + _taxFee) into 2 equal shares that add up to a maximum of 100 or nearly 100

 • so the whole amount that was sent can be reduced to the minimum


24


be removed

