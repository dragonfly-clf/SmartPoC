High
  1. Pausing functionality.
   All transfers can be stopped by a user with the “DEFAULT_ADMIN_ROLE”
   role. Such functionality is not described in the documentation.
   The rules of pausing functionality should be clear, and users should
   be informed about them.
   Contracts: DeHealthToken.sol
   Recommendation: remove the pausing functionality or describe it in
   the publicly available documentation.
   Status: Fixed
  2. Unlimited token minting.
   According to the tokenomics, the total supply of tokens is
   1,000,000,000, but the contract allows the user with the
   “DEFAULT_ADMIN_ROLE” role to mint more using __loadBalances function.
   This may lead to the impossibility of the token activation
   (“__activate” function) in case the limit of 1b tokens was minted
   using the “__loadBalances” function.
   Contracts: DeHealthToken.sol
   Function: __loadBalances
   Recommendation: limit the amount of tokens that can be minted in the
   “__loadBalances” function.
   Status: Mitigated. The token is already deployed and activated.
  