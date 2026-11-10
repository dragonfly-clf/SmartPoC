#### Informational issues


Issue File Type Line Description

#1 Main State variables that 436, 434, Add the `constant`
(BSC) could be declared 435, 430, attributes to state variables

constant (constable- 419 that never change
states)

#2 Main State variables that 714, 712, 713, Add the `constant`
(Ethersc could be declared 708, 726 attributes to state variables
an) constant (constable- that never change

states)

#### Audit Comments

##### 21. October 2021:

###### • Deployer can

 • Lock user funds (only in bscscan contract)

 • If _maxTxAmount set to 0 with setMaxTxAmount function

 • Enable/disable swapAndLiquifyEnabled

 • Set buyBackUpperLimit

 • Set liquidityFee + _taxFee to nearly 100

 • Wrong uniswap router address is set (only in etherscan version)

|Issue|File|Type|Line|Description|
|---|---|---|---|---|
|#1|Main (BSC)|State variables that could be declared constant (constable- states)|436, 434, 435, 430, 419|Add the `constant` attributes to state variables that never change|
|#2|Main (Ethersc an)|State variables that could be declared constant (constable- states)|714, 712, 713, 708, 726|Add the `constant` attributes to state variables that never change|


Main State variables that 714, 712, 713, Add the `constant`
(Ethersc could be declared 708, 726 attributes to state variables
an) constant (constable- that never change

states)

#### Audit Comments

##### 21. October 2021:

###### Deployer can

 • Lock user funds (only in bscscan contract)

 • If _maxTxAmount set to 0 with setMaxTxAmount function

 • Enable/disable swapAndLiquifyEnabled

 • Set buyBackUpperLimit

 • Set liquidityFee + _taxFee to nearly 100
 Wrong uniswap router address is set (only in etherscan version)


26


-----

