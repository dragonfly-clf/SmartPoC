7. Problematic use of safeApprove|Col2|
|---|---|
|Severity: Low|Difcfiulty: High|
|Type: Data Validation|Finding ID: TOB-ONDO-7|
|Target: contracts/BaseStablecoinStrategy.sol||


##### Description
In order for users to earn yield on the collateral tokens they deposit, the Treasury
contract sends the collateral tokens to a yield-bearing strategy contract that inherits from
the BaseStablecoinStrategy contract. When a privileged actor calls the redeem
function, the function approves the Treasury contract to pull the necessary funds from
the strategy.

However, the function approves the Treasury contract by calling the safeApprove
function.
```
  [...]
  _redeem(amount);
  stablecoin.safeApprove(getCurrentTreasury(), amount);
  emit Redeem(address(stablecoin), amount, currentPosition, profit, loss);
 }

```
_[Figure 7.1: A snippet of the redeem function in BaseStablecoinStrategy.sol:#L106–L110](https://github.com/ondoprotocol/monopoly/blob/814cfcfa04a7bfa4ae3fa395cafa329767dc67ec/contracts/strategies/BaseStablecoinStrategy.sol#L106-L110)_

As explained in the OpenZeppelin documentation, safeApprove should be called only if
the currently approved amount is zero—when setting an initial allowance or when resetting
the allowance to zero. Therefore, if the entire approved amount is not pulled by calling
```
Treasury.withdraw, subsequent redemption operations will revert.

```
Additionally, OpenZeppelin’s documentation indicates that the safeApprove function is
officially deprecated.
```
 /**
 * @dev Deprecated. This function has issues similar to the ones found in
 * {IERC20-approve}, and its usage is discouraged.
 *
 * Whenever possible, use {safeIncreaseAllowance} and
 * {safeDecreaseAllowance} instead.
 */
 function safeApprove(
   IERC20 token,

```
Trail of Bits 33 Ondo Finance Security Assessment


-----

_[Figure 7.2: The safeApprove function in SafeERC20.sol#L39–L59](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/8d908fe2c20503b05f888dd9f702e3fa6fa65840/contracts/token/ERC20/utils/SafeERC20.sol#L39-L59)_

##### Exploit Scenario
Bob, the fund manager of the Ondo protocol, deposits 200 tokens into the
```
CompoundStrategy contract and calls redeem to redeem 100 of them. However, he calls
Treasury.withdraw for only 50 tokens. Because the allowance allocated for
safeApprove has not been completely used, he is blocked from performing subsequent

```
redemption operations for the remaining 100 tokens.

##### Recommendations
Short term, use safeIncreaseAllowance and safeDecreaseAllowance instead of
```
safeApprove. Alternatively, document the fact that the Treasury should use up the

```
entire approval amount before the privileged actor can call a strategy’s redeem function.

Long term, expand the dynamic fuzz testing suite to identify edge cases like this.

Trail of Bits 34 Ondo Finance Security Assessment


-----

|