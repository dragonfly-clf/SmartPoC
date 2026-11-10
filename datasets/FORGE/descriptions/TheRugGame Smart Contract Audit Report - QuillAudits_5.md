3. Uncapped supply

 Description

 There is supply variable that has been used as a parameter in the constructor to mint a specific supply of tokens. But this does not guarantee that there won't be any more tokens minted apart from this supply which can be misleading.

 Remediation

 It is advised to use an ERC20 Capped to have a capped supply if needed. https://github.com/ OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ ERC20Capped.sol

 Status

 Acknowledged

 Informational Issues

 