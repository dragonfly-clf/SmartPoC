3. Missing functionality in the _rescueTokens function|Col2|
|---|---|
|Severity: Low|Difcfiulty: Low|
|Type: Data Validation|Finding ID: TOB-ONDO-3|
|Target: contracts/RegistryClient.sol||


##### Description
The RegistryClient contract is a helper contract designed to aid in the protocol’s
role-based access control (RBAC) mechanism. It has various helper functions that serve as
safety mechanisms to rescue funds trapped inside a contract. The inline documentation for
the _rescueTokens function states that if the _amounts array contains a zero-value entry,
then the entire token’s balance should be transferred to the caller. However, this
functionality is not present in the code; instead, the function sends zero tokens to the caller
on a zero-value entry.
```
 * @dev If the _amount[i] is 0, then transfer all the tokens
 *
 * @param _tokens List of tokens
 * @param _amounts Amount of each token to send
 */
 function _rescueTokens(address[] calldata _tokens, uint256[] memory _amounts)
  internal
  virtual
 {
  for (uint256 i = 0; i < _tokens.length; i++) {
   uint256 amount = _amounts[i];
   IERC20(_tokens[i]).safeTransfer(msg.sender, amount);
  }
 }

```
_[Figure 3.1: The _rescueTokens function in RegistryClient.sol:#L192–L205](https://github.com/ondoprotocol/monopoly/blob/814cfcfa04a7bfa4ae3fa395cafa329767dc67ec/contracts/registry/RegistryClient.sol#L197-L205)_

##### Exploit Scenario
A user accidentally sends ERC20 tokens to the PSM contract. To rescue the tokens, Bob, the
guardian of the Ondo protocol contracts, calls _rescueTokens and specifies zero as the
amount for the ERC20 tokens in question. However, the contract incorrectly transfers zero
tokens to him and, therefore, the funds are not rescued.

##### Recommendations
Short term, adjust the _rescueTokens function so that it transfers the entire token
balance when it reaches a zero-value entry in the _amounts array.

Trail of Bits 27 Ondo Finance Security Assessment


-----

Long term, improve the unit test coverage to cover additional edge cases and to ensure
that the system behaves as expected.

Trail of Bits 28 Ondo Finance Security Assessment


-----

|