A11. Uncheck Return Value:

 Description

 HoldingContract.initiate(address,uint256) (contracts/TokenContract.sol#87-92) ignores return value by ERC20Interface(MAINCONTRACT).transferinternal(this,receiver,tokens) (contracts/ TokenContract.sol#91) CleverMinu.IMOreferral(address,uint256) (contracts/TokenContract.sol#156-164) ignores return value by ERC20Interface(this).transferinternal(this,to,amount) (contracts/ TokenContract.sol#162)

 Remediation

 It is advised to add specific require checks on the return values

 Refer: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return

 Status

 Resolved


-----

###### Informational Issues

 