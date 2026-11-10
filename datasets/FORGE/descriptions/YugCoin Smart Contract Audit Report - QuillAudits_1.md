2. Centralization issues

 Description

 All power and core functionality is centralized in the owner. If the owner account gets compromised, the entire project is at risk of token loss, price manipulation, denial of service.
 The addLiquidityETH function call sends LP tokens to owner(), if owner is compromised, LP tokens can be mismanaged as well which could lead to price manipulation.

 Remediation

 Have the private key of the owner account carefully managed, we strongly recommend centralized privileges or roles in the protocol to be improved via a decentralized mechanism or smart-contract-based accounts with enhanced security practices, e.g., Multisignature wallets.
 Have the LP tokens sent to an account with more control, for example: the contract itself with checks to ensure the tokens are not mismanaged.

 Status

 Acknowledged

 Comment: Team will be utilizing Gnosis Safe to lower the risks of a centralization exploit.

 Medium Severity Issues

 