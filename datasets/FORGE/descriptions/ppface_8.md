#### ULTW - Transfers Liquidity to Team Wallet

**Criticality** Minor / Informative

**Location** Token.sol#L435

**Status** Unresolved

#### Description

The contract owner has the authority to transfer funds without limit to the team wallet.

These funds have been accumulated from fees collected from the contract. The owner may

take advantage of it by calling the `setFeeDistribution` function and set the

`sellfee` to zero.
```
 function internalSwap(uint256 balanceBefore) internal
 inSwapFlag {
      ...
      if (sellfee > 0) {
        ...
      } else if (balanceOf(address(this)) > 0) {
 swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
          balanceOf(address(this)),
          0,
          path,
          address(this),
          block.timestamp
        );
        uint256 amountETH =
 address(this).balance.sub(balanceBefore);
         (success,) = marketingAddress.call{value:
 amountETH, gas: 35000}("");
        require(success, "Failed to send ETH to marketing
 fee receiver");
      }

#### Recommendation

```
The contract could embody a check for the maximum amount of funds that can be

swapped, since a huge amount may volatile the token's price. The team should carefully

manage the private keys of the owner’s account. We strongly recommend a powerful


-----

security mechanism that will prevent a single user from accessing the contract admin

functions. Some suggestions are:

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a multi-sign wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.

  - Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

