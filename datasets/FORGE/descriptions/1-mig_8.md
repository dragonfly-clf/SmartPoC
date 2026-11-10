#### L20 - Succeeded Transfer Check

**Criticality** Minor / Informative

**Location** CoinToken.sol#L1133

**Status** Unresolved

#### Description

According to the ERC20 specification, the transfer methods should be checked if the result

is successful. Otherwise, the contract may wrongly assume that the transfer has been

established.
```
 IERC20(tokenAddress).transfer(owner(), tokenAmount)

#### Recommendation

```
The contract should check if the result of the transfer methods is successful. The team is

[advised to check the SafeERC20 library from the Openzeppelin library.](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol)