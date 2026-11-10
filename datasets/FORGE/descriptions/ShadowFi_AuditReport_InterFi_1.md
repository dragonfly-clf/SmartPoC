v ShadowFi’s smart contracts have active ownership.


-----

## Static Analysis

#### Symbol Meaning

 🛑 Function can modify state

 💵 Function is payable

 🔒 Function is locked

 🔐 Function can be accessed

 ❗ Important functionality
```
| **ReentrancyGuard** | Implementation | |||
| └ | <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | _nonReentrantBefore | Private 🔐 | 🛑 | |
| └ | _nonReentrantAfter | Private 🔐 | 🛑 | |
||||||
| **Context** | Implementation | |||
| └ | _msgSender | Internal 🔒 |  | |
| └ | _msgData | Internal 🔒 |  | |
||||||
| **Ownable** | Implementation | Context |||
| └ | <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | owner | Public ❗ |  |NO❗ |
| └ | transferOwnership | Public ❗ | 🛑 | onlyOwner |

```

#### 🛑


#### 🔒


#### ❗

```
| └ | _transferOwnership | Internal 🔒 | 🛑 | |

```

#### 💵

```
||||||
| **IShadowFiToken** | Interface | |||
| └ | totalSupply | External ❗ |  |NO❗ |
| └ | balanceOf | External ❗ |  |NO❗ |
| └ | transfer | External ❗ | 🛑 |NO❗ |
| └ | allowance | External ❗ |  |NO❗ |
| └ | approve | External ❗ | 🛑 |NO❗ |
| └ | isAirdropped | External ❗ |  |NO❗ |
| └ | transferFrom | External ❗ | 🛑 |NO❗ |
| └ | decimals | External ❗ |  |NO❗ |
||||||
| **ShadowFiPresale** | Implementation | Ownable, ReentrancyGuard |||
| └ | <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | depositTokens | Public ❗ | 🛑 | onlyOwner |
| └ | withdrawTokens | Public ❗ | 🛑 | onlyOwner |
| └ | setCost | Public ❗ | 🛑 | onlyOwner |

```

#### Function is payable

 Function is locked

 Function can be accessed

 Important functionality
```
**ReentrancyGuard** | Implementation | |||
 <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | _nonReentrantBefore | Private 🔐 | 🛑 | |
| └ | _nonReentrantAfter | Private 🔐 | 🛑 | |
**Context** | Implementation | |||
| └ | _msgSender | Internal 🔒 |  | |
| └ | _msgData | Internal 🔒 |  | |
**Ownable** | Implementation | Context |||
 <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | owner | Public ❗ |  |NO❗ |
| └ | transferOwnership | Public ❗ | 🛑 | onlyOwner |
| └ | _transferOwnership | Internal 🔒 | 🛑 | |
**IShadowFiToken** | Interface | |||
| └ | totalSupply | External ❗ |  |NO❗ |
| └ | balanceOf | External ❗ |  |NO❗ |
| └ | transfer | External ❗ | 🛑 |NO❗ |
| └ | allowance | External ❗ |  |NO❗ |
| └ | approve | External ❗ | 🛑 |NO❗ |
| └ | isAirdropped | External ❗ |  |NO❗ |
| └ | transferFrom | External ❗ | 🛑 |NO❗ |
| └ | decimals | External ❗ |  |NO❗ |

```

#### 🔐


🛑


🛑


🛑


🛑


-----

```
| └ | setToken | Public ❗ | 🛑 | onlyOwner |
| └ | setDiscount | Public ❗ | 🛑 | onlyOwner |
| └ | setStartandStopTime | Public ❗ | 🛑 | onlyOwner |
| └ | setMax | Public ❗ | 🛑 | onlyOwner |
| └ | setMin | Public ❗ | 🛑 | onlyOwner |
| └ | withdraw | Public ❗ | 🛑 | onlyOwner |
| └ | tokenAddress | Public ❗ |  |NO❗ |
| └ | availableForSaleTokenAmount | Public ❗ |  |NO❗ |
| └ | totalBoughtByUserTokenAmount | Public ❗ |  |NO❗ |
| └ | totalSoldTokenAmount | Public ❗ |  |NO❗ |
| └ | tokenCostBNB | Public ❗ |  |NO❗ |
| └ | totalBNBRaisedSoFar | Public ❗ |  |NO❗ |
| └ | discountPercentage | Public ❗ |  |NO❗ |
| └ | maxBuyableTokenAmount | Public ❗ |  |NO❗ |
| └ | getStartTime | Public ❗ |  |NO❗ |
| └ | getStopTime | Public ❗ |  |NO❗ |
| └ | buy | External ❗ | 💵 | nonReentrant |
| **Context** | Implementation | |||
| └ | _msgSender | Internal 🔒 |  | |
| └ | _msgData | Internal 🔒 |  | |
||||||
| **IPancakeRouter** | Interface | |||
| └ | factory | External ❗ |  |NO❗ |
| └ | WETH | External ❗ |  |NO❗ |
| └ | addLiquidity | External ❗ | 🛑 |NO❗ |
| └ | addLiquidityETH | External ❗ | 💵 |NO❗ |
| └ | removeLiquidity | External ❗ | 🛑 |NO❗ |
| └ | removeLiquidityETH | External ❗ | 🛑 |NO❗ |
| └ | removeLiquidityWithPermit | External ❗ | 🛑 |NO❗ |
| └ | removeLiquidityETHWithPermit | External ❗ | 🛑 |NO❗ |
| └ | swapExactTokensForTokens | External ❗ | 🛑 |NO❗ |
| └ | swapTokensForExactTokens | External ❗ | 🛑 |NO❗ |
| └ | swapExactETHForTokens | External ❗ | 💵 |NO❗ |
| └ | swapTokensForExactETH | External ❗ | 🛑 |NO❗ |
| └ | swapExactTokensForETH | External ❗ | 🛑 |NO❗ |
| └ | swapETHForExactTokens | External ❗ | 💵 |NO❗ |
| └ | quote | External ❗ |  |NO❗ |
| └ | getAmountOut | External ❗ |  |NO❗ |
| └ | getAmountIn | External ❗ |  |NO❗ |
| └ | getAmountsOut | External ❗ |  |NO❗ |
| └ | getAmountsIn | External ❗ |  |NO❗ |
| └ | removeLiquidityETHSupportingFeeOnTransferTokens | External ❗ | 🛑 |NO❗ |
| └ | removeLiquidityETHWithPermitSupportingFeeOnTransferTokens | External ❗ | 🛑 |NO❗ |
| └ | swapExactTokensForTokensSupportingFeeOnTransferTokens | External ❗ | 🛑 |NO❗ |
| └ | swapExactETHForTokensSupportingFeeOnTransferTokens | External ❗ | 💵 |NO❗ |
| └ | swapExactTokensForETHSupportingFeeOnTransferTokens | External ❗ | 🛑 |NO❗ |
||||||
| **IPancakeFactory** | Interface | |||
| └ | getPair | External ❗ |  |NO❗ |

```
```
| └ | availableForSaleTokenAmount | Public ❗ |  |NO❗ |
| └ | totalBoughtByUserTokenAmount | Public ❗ |  |NO❗ |
| └ | totalSoldTokenAmount | Public ❗ |  |NO❗ |
| └ | tokenCostBNB | Public ❗ |  |NO❗ |
| └ | totalBNBRaisedSoFar | Public ❗ |  |NO❗ |
| └ | discountPercentage | Public ❗ |  |NO❗ |
| └ | maxBuyableTokenAmount | Public ❗ |  |NO❗ |
| └ | getStartTime | Public ❗ |  |NO❗ |
| └ | getStopTime | Public ❗ |  |NO❗ |
| └ | buy | External ❗ | 💵 | nonReentrant |
**Context** | Implementation | |||
| └ | _msgSender | Internal 🔒 |  | |
| └ | _msgData | Internal 🔒 |  | |
**IPancakeRouter** | Interface | |||
| └ | factory | External ❗ |  |NO❗ |
| └ | WETH | External ❗ |  |NO❗ |
| └ | addLiquidity | External ❗ | 🛑 |NO❗ |
| └ | addLiquidityETH | External ❗ | 💵 |NO❗ |
| └ | removeLiquidity | External ❗ | 🛑 |NO❗ |
| └ | removeLiquidityETH | External ❗ | 🛑 |NO❗ |
| └ | removeLiquidityWithPermit | External ❗ | 🛑 |NO❗ |
| └ | removeLiquidityETHWithPermit | External ❗ | 🛑 |NO❗ |
| └ | swapExactTokensForTokens | External ❗ | 🛑 |NO❗ |
| └ | swapTokensForExactTokens | External ❗ | 🛑 |NO❗ |
| └ | swapExactETHForTokens | External ❗ | 💵 |NO❗ |
| └ | swapTokensForExactETH | External ❗ | 🛑 |NO❗ |
| └ | swapExactTokensForETH | External ❗ | 🛑 |NO❗ |
| └ | swapETHForExactTokens | External ❗ | 💵 |NO❗ |
| └ | quote | External ❗ |  |NO❗ |
| └ | getAmountOut | External ❗ |  |NO❗ |
| └ | getAmountIn | External ❗ |  |NO❗ |
| └ | getAmountsOut | External ❗ |  |NO❗ |
| └ | getAmountsIn | External ❗ |  |NO❗ |
| └ | removeLiquidityETHSupportingFeeOnTransferTokens | External ❗ | 🛑 |NO❗ |
| └ | removeLiquidityETHWithPermitSupportingFeeOnTransferTokens | External ❗ | 🛑 |NO❗ |

```

❗


❗


❗


❗


❗


❗


❗


❗


❗


🛑


❗


❗


🛑


❗


-----

```
||||||
| **IPancakePair** | Interface | |||
| └ | name | External ❗ |  |NO❗ |
| └ | symbol | External ❗ |  |NO❗ |
| └ | decimals | External ❗ |  |NO❗ |
| └ | totalSupply | External ❗ |  |NO❗ |
| └ | balanceOf | External ❗ |  |NO❗ |
| └ | allowance | External ❗ |  |NO❗ |
| └ | approve | External ❗ | 🛑 |NO❗ |
| └ | transfer | External ❗ | 🛑 |NO❗ |
| └ | transferFrom | External ❗ | 🛑 |NO❗ |
| └ | DOMAIN_SEPARATOR | External ❗ |  |NO❗ |
| └ | PERMIT_TYPEHASH | External ❗ |  |NO❗ |
| └ | nonces | External ❗ |  |NO❗ |
| └ | permit | External ❗ | 🛑 |NO❗ |
| └ | MINIMUM_LIQUIDITY | External ❗ |  |NO❗ |
| └ | factory | External ❗ |  |NO❗ |
| └ | token0 | External ❗ |  |NO❗ |
| └ | token1 | External ❗ |  |NO❗ |
| └ | getReserves | External ❗ |  |NO❗ |
| └ | price0CumulativeLast | External ❗ |  |NO❗ |
| └ | price1CumulativeLast | External ❗ |  |NO❗ |
| └ | kLast | External ❗ |  |NO❗ |
| └ | mint | External ❗ | 🛑 |NO❗ |
| └ | burn | External ❗ | 🛑 |NO❗ |
| └ | swap | External ❗ | 🛑 |NO❗ |
| └ | skim | External ❗ | 🛑 |NO❗ |
| └ | sync | External ❗ | 🛑 |NO❗ |
| └ | initialize | External ❗ | 🛑 |NO❗ |
||||||
| **IShadowFiToken** | Interface | |||
| └ | totalSupply | External ❗ |  |NO❗ |
| └ | balanceOf | External ❗ |  |NO❗ |
| └ | transfer | External ❗ | 🛑 |NO❗ |
| └ | allowance | External ❗ |  |NO❗ |
| └ | approve | External ❗ | 🛑 |NO❗ |
| └ | isAirdropped | External ❗ |  |NO❗ |
| └ | transferFrom | External ❗ | 🛑 |NO❗ |
| └ | decimals | External ❗ |  |NO❗ |
| └ | burn | External ❗ | 🛑 |NO❗ |
||||||
| **IERC20** | Interface | |||
| └ | transfer | External ❗ | 🛑 |NO❗ |
| └ | balanceOf | External ❗ |  |NO❗ |
| └ | approve | External ❗ | 🛑 |NO❗ |
||||||
| **IWETH** | Interface | |||
| └ | deposit | External ❗ | 💵 |NO❗ |
| └ | transfer | External ❗ | 🛑 |NO❗ |
| └ | withdraw | External ❗ | 🛑 |NO❗ |

```
```
| └ | allowance | External ❗ |  |NO❗ |
| └ | approve | External ❗ | 🛑 |NO❗ |
| └ | transfer | External ❗ | 🛑 |NO❗ |
| └ | transferFrom | External ❗ | 🛑 |NO❗ |
| └ | DOMAIN_SEPARATOR | External ❗ |  |NO❗ |
| └ | PERMIT_TYPEHASH | External ❗ |  |NO❗ |
| └ | nonces | External ❗ |  |NO❗ |
| └ | permit | External ❗ | 🛑 |NO❗ |
| └ | MINIMUM_LIQUIDITY | External ❗ |  |NO❗ |
| └ | factory | External ❗ |  |NO❗ |
| └ | token0 | External ❗ |  |NO❗ |
| └ | token1 | External ❗ |  |NO❗ |
| └ | getReserves | External ❗ |  |NO❗ |
| └ | price0CumulativeLast | External ❗ |  |NO❗ |
| └ | price1CumulativeLast | External ❗ |  |NO❗ |
| └ | kLast | External ❗ |  |NO❗ |
| └ | mint | External ❗ | 🛑 |NO❗ |
| └ | burn | External ❗ | 🛑 |NO❗ |
| └ | swap | External ❗ | 🛑 |NO❗ |
| └ | skim | External ❗ | 🛑 |NO❗ |
| └ | sync | External ❗ | 🛑 |NO❗ |
| └ | initialize | External ❗ | 🛑 |NO❗ |
**IShadowFiToken** | Interface | |||
| └ | totalSupply | External ❗ |  |NO❗ |
| └ | balanceOf | External ❗ |  |NO❗ |
| └ | transfer | External ❗ | 🛑 |NO❗ |
| └ | allowance | External ❗ |  |NO❗ |
| └ | approve | External ❗ | 🛑 |NO❗ |
| └ | isAirdropped | External ❗ |  |NO❗ |
| └ | transferFrom | External ❗ | 🛑 |NO❗ |
| └ | decimals | External ❗ |  |NO❗ |
| └ | burn | External ❗ | 🛑 |NO❗ |
**IERC20** | Interface | |||
| └ | transfer | External ❗ | 🛑 |NO❗ |
| └ | balanceOf | External ❗ |  |NO❗ |

```

❗


❗


❗


❗


❗


❗


❗


❗


💵


❗


❗


🛑


-----

```
||||||
| **ShadowFiLiquidityLock** | Implementation | Ownable, ReentrancyGuard |||
| └ | <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | endLock | Public ❗ | 🛑 | onlyOwner |
| └ | extendLockTime | Public ❗ | 🛑 | onlyOwner |
| └ | withdrawBNB | Public ❗ | 🛑 | onlyOwner |
| └ | withdrawTokens | Public ❗ | 🛑 | onlyOwner |
| └ | shadowStrike | Public ❗ | 🛑 | onlyOwner |
| └ | shadowBurst | Public ❗ | 🛑 | onlyOwner |
| └ | getLPOwnershipPercent | Public ❗ |  |NO❗ |
| └ | getLiquidTokens | Public ❗ |  |NO❗ |
| └ | getLiquidPercent | Public ❗ |  |NO❗ |
| └ | getRemoveAmountForBuyAndBurnExcess | Public ❗ |  |NO❗ |
| └ | getRemoveAmountForBuyAndBurnExcessAmount | Public ❗ |  |NO❗ |
| └ | addLiquidity | External ❗ | 💵 | onlyOwner nonReentrant |
| └ | getLockTime | Public ❗ |  |NO❗ |
| └ | <Receive Ether> | External ❗ | 💵 |NO❗ |
| └ | <Fallback> | External ❗ | 💵 |NO❗ |
| **SafeMath** | Library | |||
| └ | add | Internal 🔒 |  | |
| └ | sub | Internal 🔒 |  | |
| └ | sub | Internal 🔒 |  | |
| └ | mul | Internal 🔒 |  | |
| └ | div | Internal 🔒 |  | |
| └ | div | Internal 🔒 |  | |
||||||
| **IBEP20** | Interface | |||
| └ | totalSupply | External ❗ |  |NO❗ |
| └ | decimals | External ❗ |  |NO❗ |
| └ | symbol | External ❗ |  |NO❗ |
| └ | name | External ❗ |  |NO❗ |
| └ | getOwner | External ❗ |  |NO❗ |
| └ | balanceOf | External ❗ |  |NO❗ |
| └ | transfer | External ❗ | 🛑 |NO❗ |
| └ | allowance | External ❗ |  |NO❗ |
| └ | approve | External ❗ | 🛑 |NO❗ |
| └ | transferFrom | External ❗ | 🛑 |NO❗ |
||||||
| **IDEXFactory** | Interface | |||
| └ | createPair | External ❗ | 🛑 |NO❗ |
||||||
| **IDEXRouter** | Interface | |||
| └ | factory | External ❗ |  |NO❗ |
| └ | WETH | External ❗ |  |NO❗ |
| └ | addLiquidity | External ❗ | 🛑 |NO❗ |
| └ | addLiquidityETH | External ❗ | 💵 |NO❗ |
| └ | swapExactTokensForTokensSupportingFeeOnTransferTokens | External ❗ | 🛑 |NO❗ |
| └ | swapExactETHForTokensSupportingFeeOnTransferTokens | External ❗ | 💵 |NO❗ |
| └ | swapExactTokensForETHSupportingFeeOnTransferTokens | External ❗ | 🛑 |NO❗ |

```
```
| └ | shadowStrike | Public ❗ | 🛑 | onlyOwner |
| └ | shadowBurst | Public ❗ | 🛑 | onlyOwner |
| └ | getLPOwnershipPercent | Public ❗ |  |NO❗ |
| └ | getLiquidTokens | Public ❗ |  |NO❗ |
| └ | getLiquidPercent | Public ❗ |  |NO❗ |
| └ | getRemoveAmountForBuyAndBurnExcess | Public ❗ |  |NO❗ |
| └ | getRemoveAmountForBuyAndBurnExcessAmount | Public ❗ |  |NO❗ |
| └ | addLiquidity | External ❗ | 💵 | onlyOwner nonReentrant |
| └ | getLockTime | Public ❗ |  |NO❗ |
 <Receive Ether> | External ❗ | 💵 |NO❗ |
 <Fallback> | External ❗ | 💵 |NO❗ |
**SafeMath** | Library | |||
| └ | add | Internal 🔒 |  | |
| └ | sub | Internal 🔒 |  | |
| └ | sub | Internal 🔒 |  | |
| └ | mul | Internal 🔒 |  | |
| └ | div | Internal 🔒 |  | |
| └ | div | Internal 🔒 |  | |
**IBEP20** | Interface | |||
| └ | totalSupply | External ❗ |  |NO❗ |
| └ | decimals | External ❗ |  |NO❗ |
| └ | symbol | External ❗ |  |NO❗ |
| └ | name | External ❗ |  |NO❗ |
| └ | getOwner | External ❗ |  |NO❗ |
| └ | balanceOf | External ❗ |  |NO❗ |
| └ | transfer | External ❗ | 🛑 |NO❗ |
| └ | allowance | External ❗ |  |NO❗ |
| └ | approve | External ❗ | 🛑 |NO❗ |
| └ | transferFrom | External ❗ | 🛑 |NO❗ |
**IDEXFactory** | Interface | |||
| └ | createPair | External ❗ | 🛑 |NO❗ |
**IDEXRouter** | Interface | |||
| └ | factory | External ❗ |  |NO❗ |

```

❗


❗


❗


❗


❗


❗


❗


❗


❗


💵


❗


❗


💵


❗


❗


-----

```
||||||
| **ShadowAuth** | Implementation | |||
| └ | <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | authorizeFor | Public ❗ | 🛑 | authorizedFor |
| └ | authorizeForMultiplePermissions | Public ❗ | 🛑 | authorizedFor |
| └ | unauthorizeFor | Public ❗ | 🛑 | authorizedFor |
| └ | unauthorizeForMultiplePermissions | Public ❗ | 🛑 | authorizedFor |
| └ | isOwner | Public ❗ |  |NO❗ |
| └ | isAuthorizedFor | Public ❗ |  |NO❗ |
| └ | isAuthorizedFor | Public ❗ |  |NO❗ |
| └ | transferOwnership | Public ❗ | 🛑 | onlyOwner |
| └ | getPermissionNameToIndex | Public ❗ |  |NO❗ |
| └ | getPermissionUnlockTime | Public ❗ |  |NO❗ |
| └ | isLocked | Public ❗ |  |NO❗ |
| └ | lockPermission | Public ❗ | 🛑 | authorizedFor |
| └ | unlockPermission | Public ❗ | 🛑 |NO❗ |
||||||
| **IDividendDistributor** | Interface | |||
| └ | setDistributionCriteria | External ❗ | 🛑 |NO❗ |
| └ | setShare | External ❗ | 🛑 |NO❗ |
| └ | deposit | External ❗ | 💵 |NO❗ |
| └ | process | External ❗ | 🛑 |NO❗ |
| └ | claimDividend | External ❗ | 🛑 |NO❗ |
||||||
| **DividendDistributor** | Implementation | IDividendDistributor |||
| └ | <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | setDistributionCriteria | External ❗ | 🛑 | onlyToken |
| └ | setShare | External ❗ | 🛑 | onlyToken |
| └ | deposit | External ❗ | 💵 | onlyToken |
| └ | process | External ❗ | 🛑 | onlyToken |
| └ | shouldDistribute | Internal 🔒 |  | |
| └ | distributeDividend | Internal 🔒 | 🛑 | |
| └ | claimDividend | External ❗ | 🛑 |NO❗ |
| └ | getUnpaidEarnings | Public ❗ |  |NO❗ |
| └ | getCumulativeDividends | Internal 🔒 |  | |
| └ | addShareholder | Internal 🔒 | 🛑 | |
| └ | removeShareholder | Internal 🔒 | 🛑 | |
||||||
| **ShadowFi** | Implementation | IBEP20, ShadowAuth |||
| └ | <Constructor> | Public ❗ | 🛑 | ShadowAuth |
| └ | <Receive Ether> | External ❗ | 💵 |NO❗ |
| └ | totalSupply | External ❗ |  |NO❗ |
| └ | decimals | External ❗ |  |NO❗ |
| └ | symbol | External ❗ |  |NO❗ |
| └ | name | External ❗ |  |NO❗ |
| └ | getOwner | External ❗ |  |NO❗ |
| └ | balanceOf | Public ❗ |  |NO❗ |
| └ | allowance | External ❗ |  |NO❗ |
| └ | approve | Public ❗ | 🛑 |NO❗ |
| └ | approveMax | External ❗ | 🛑 |NO❗ |

```
```
| └ | isOwner | Public ❗ |  |NO❗ |
| └ | isAuthorizedFor | Public ❗ |  |NO❗ |
| └ | isAuthorizedFor | Public ❗ |  |NO❗ |
| └ | transferOwnership | Public ❗ | 🛑 | onlyOwner |
| └ | getPermissionNameToIndex | Public ❗ |  |NO❗ |
| └ | getPermissionUnlockTime | Public ❗ |  |NO❗ |
| └ | isLocked | Public ❗ |  |NO❗ |
| └ | lockPermission | Public ❗ | 🛑 | authorizedFor |
| └ | unlockPermission | Public ❗ | 🛑 |NO❗ |
**IDividendDistributor** | Interface | |||
| └ | setDistributionCriteria | External ❗ | 🛑 |NO❗ |
| └ | setShare | External ❗ | 🛑 |NO❗ |
| └ | deposit | External ❗ | 💵 |NO❗ |
| └ | process | External ❗ | 🛑 |NO❗ |
| └ | claimDividend | External ❗ | 🛑 |NO❗ |
**DividendDistributor** | Implementation | IDividendDistributor |||
 <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | setDistributionCriteria | External ❗ | 🛑 | onlyToken |
| └ | setShare | External ❗ | 🛑 | onlyToken |
| └ | deposit | External ❗ | 💵 | onlyToken |
| └ | process | External ❗ | 🛑 | onlyToken |
| └ | shouldDistribute | Internal 🔒 |  | |
| └ | distributeDividend | Internal 🔒 | 🛑 | |
| └ | claimDividend | External ❗ | 🛑 |NO❗ |
| └ | getUnpaidEarnings | Public ❗ |  |NO❗ |
| └ | getCumulativeDividends | Internal 🔒 |  | |
| └ | addShareholder | Internal 🔒 | 🛑 | |
| └ | removeShareholder | Internal 🔒 | 🛑 | |
**ShadowFi** | Implementation | IBEP20, ShadowAuth |||
 <Constructor> | Public ❗ | 🛑 | ShadowAuth |
 <Receive Ether> | External ❗ | 💵 |NO❗ |
| └ | totalSupply | External ❗ |  |NO❗ |
| └ | decimals | External ❗ |  |NO❗ |
| └ | symbol | External ❗ |  |NO❗ |

```

❗


❗


❗


❗


❗


❗


❗


❗


❗


❗


❗


❗


🛑


❗


-----

```
| └ | transfer | External ❗ | 🛑 |NO❗ |
| └ | transferFrom | External ❗ | 🛑 |NO❗ |
| └ | _transferFrom | Internal 🔒 | 🛑 | |
| └ | _basicTransfer | Internal 🔒 | 🛑 | |
| └ | checkTxLimit | Internal 🔒 |  | |
| └ | shouldTakeFee | Internal 🔒 |  | |
| └ | getTotalFee | Public ❗ |  |NO❗ |
| └ | getMultipliedFee | Public ❗ |  |NO❗ |
| └ | takeFee | Internal 🔒 | 🛑 | |
| └ | isSell | Internal 🔒 |  | |
| └ | shouldSwapBack | Internal 🔒 |  | |
| └ | swapBack | Internal 🔒 | 🛑 | swapping |
| └ | triggerBuyback | External ❗ | 🛑 | authorizedFor |
| └ | clearBuybackMultiplier | External ❗ | 🛑 | authorizedFor |
| └ | buyTokens | Internal 🔒 | 🛑 | swapping |
| └ | setBuybackMultiplierSettings | External ❗ | 🛑 | authorizedFor |
| └ | launched | Internal 🔒 |  | |
| └ | launch | Internal 🔒 | 🛑 | |
| └ | setTxLimit | External ❗ | 🛑 | authorizedFor |
| └ | setIsDividendExempt | External ❗ | 🛑 | authorizedFor |
| └ | setIsFeeExempt | External ❗ | 🛑 | authorizedFor |
| └ | setIsTxLimitExempt | External ❗ | 🛑 | authorizedFor |
| └ | setFees | External ❗ | 🛑 | authorizedFor |
| └ | setFeeReceivers | External ❗ | 🛑 | authorizedFor |
| └ | setSwapBackSettings | External ❗ | 🛑 | authorizedFor |
| └ | setTargetLiquidity | External ❗ | 🛑 | authorizedFor |
| └ | setDistributionCriteria | External ❗ | 🛑 | authorizedFor |
| └ | setDistributorSettings | External ❗ | 🛑 | authorizedFor |
| └ | getCirculatingSupply | Public ❗ |  |NO❗ |
| └ | getLiquidityBacking | Public ❗ |  |NO❗ |
| └ | isOverLiquified | Public ❗ |  |NO❗ |
| └ | claimDividend | External ❗ | 🛑 |NO❗ |
| └ | addPair | External ❗ | 🛑 | authorizedFor |
| └ | removeLastPair | External ❗ | 🛑 | authorizedFor |
| └ | setFeesOnNormalTransfers | External ❗ | 🛑 | authorizedFor |
| └ | setLaunchedAt | External ❗ | 🛑 | authorizedFor |
| └ | setAllowedAddress | External ❗ | 🛑 | onlyOwner |
| └ | burn | Public ❗ | 🛑 |NO❗ |
| └ | airdrop | External ❗ | 🛑 | onlyOwner |
| └ | isAirdropped | External ❗ |  |NO❗ |
| └ | setBlackListed | External ❗ | 🛑 | onlyOwner |

```
```
| └ | getMultipliedFee | Public ❗ |  |NO❗ |
| └ | takeFee | Internal 🔒 | 🛑 | |
| └ | isSell | Internal 🔒 |  | |
| └ | shouldSwapBack | Internal 🔒 |  | |
| └ | swapBack | Internal 🔒 | 🛑 | swapping |
| └ | triggerBuyback | External ❗ | 🛑 | authorizedFor |
| └ | clearBuybackMultiplier | External ❗ | 🛑 | authorizedFor |
| └ | buyTokens | Internal 🔒 | 🛑 | swapping |
| └ | setBuybackMultiplierSettings | External ❗ | 🛑 | authorizedFor |
| └ | launched | Internal 🔒 |  | |
| └ | launch | Internal 🔒 | 🛑 | |
| └ | setTxLimit | External ❗ | 🛑 | authorizedFor |
| └ | setIsDividendExempt | External ❗ | 🛑 | authorizedFor |
| └ | setIsFeeExempt | External ❗ | 🛑 | authorizedFor |
| └ | setIsTxLimitExempt | External ❗ | 🛑 | authorizedFor |
| └ | setFees | External ❗ | 🛑 | authorizedFor |
| └ | setFeeReceivers | External ❗ | 🛑 | authorizedFor |
| └ | setSwapBackSettings | External ❗ | 🛑 | authorizedFor |
| └ | setTargetLiquidity | External ❗ | 🛑 | authorizedFor |
| └ | setDistributionCriteria | External ❗ | 🛑 | authorizedFor |
| └ | setDistributorSettings | External ❗ | 🛑 | authorizedFor |
| └ | getCirculatingSupply | Public ❗ |  |NO❗ |
| └ | getLiquidityBacking | Public ❗ |  |NO❗ |
| └ | isOverLiquified | Public ❗ |  |NO❗ |
| └ | claimDividend | External ❗ | 🛑 |NO❗ |
| └ | addPair | External ❗ | 🛑 | authorizedFor |
| └ | removeLastPair | External ❗ | 🛑 | authorizedFor |
| └ | setFeesOnNormalTransfers | External ❗ | 🛑 | authorizedFor |
| └ | setLaunchedAt | External ❗ | 🛑 | authorizedFor |
| └ | setAllowedAddress | External ❗ | 🛑 | onlyOwner |
| └ | burn | Public ❗ | 🛑 |NO❗ |
| └ | airdrop | External ❗ | 🛑 | onlyOwner |
| └ | isAirdropped | External ❗ |  |NO❗ |
| └ | setBlackListed | External ❗ | 🛑 | onlyOwner |

```

❗


❗


🛑


🔒


🔒


🔒


❗


-----

## Software Analysis

### Function Signatures
```
18160ddd => totalSupply()
313ce567 => decimals()
95d89b41 => symbol()
06fdde03 => name()
893d20e8 => getOwner()
70a08231 => balanceOf(address)
a9059cbb => transfer(address,uint256)
dd62ed3e => allowance(address,address)
095ea7b3 => approve(address,uint256)
23b872dd => transferFrom(address,address,uint256)
c9c65396 => createPair(address,address)
c45a0155 => factory()
ad5c4648 => WETH()
e8e33700 => addLiquidity(address,address,uint256,uint256,uint256,uint256,address,uint256)
f305d719 => addLiquidityETH(address,uint256,uint256,uint256,address,uint256)
5c11d795 => 
swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)
b6f9de95 => swapExactETHForTokensSupportingFeeOnTransferTokens(uint256,address[],address,uint256)
791ac947 => 
swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)
1e8f5283 => authorizeFor(address,string)
af05cf93 => authorizeForMultiplePermissions(address,string[])
8101cae3 => unauthorizeFor(address,string)
1ad6084f => unauthorizeForMultiplePermissions(address,string[])
2f54bf6e => isOwner(address)
c41235a6 => isAuthorizedFor(address,string)
7a511001 => isAuthorizedFor(address,Permission)
f2fde38b => transferOwnership(address)
06fbdcd8 => getPermissionNameToIndex(string)
e75cae79 => getPermissionUnlockTime(string)
8032eccb => isLocked(string)
971563fc => lockPermission(string,uint64)
07858b02 => unlockPermission(string)
2d48e896 => setDistributionCriteria(uint256,uint256)
14b6ca96 => setShare(address,uint256)
d0e30db0 => deposit()
ffb2c479 => process(uint256)
f0fc6bca => claimDividend()
8c21cd52 => shouldDistribute(address)
5319504a => distributeDividend(address)
28fd3198 => getUnpaidEarnings(address)
e68af3ac => getCumulativeDividends(uint256)
db29fe12 => addShareholder(address)
9babdad6 => removeShareholder(address)
571ac8b0 => approveMax(address)

```
```
95d89b41 => symbol()
06fdde03 => name()
893d20e8 => getOwner()
70a08231 => balanceOf(address)
a9059cbb => transfer(address,uint256)
dd62ed3e => allowance(address,address)
095ea7b3 => approve(address,uint256)
23b872dd => transferFrom(address,address,uint256)
c9c65396 => createPair(address,address)
c45a0155 => factory()
ad5c4648 => WETH()
e8e33700 => addLiquidity(address,address,uint256,uint256,uint256,uint256,address,uint256)
f305d719 => addLiquidityETH(address,uint256,uint256,uint256,address,uint256)
5c11d795 => 
swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)
b6f9de95 => swapExactETHForTokensSupportingFeeOnTransferTokens(uint256,address[],address,uint256)
791ac947 => 
swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)
1e8f5283 => authorizeFor(address,string)
af05cf93 => authorizeForMultiplePermissions(address,string[])
8101cae3 => unauthorizeFor(address,string)
1ad6084f => unauthorizeForMultiplePermissions(address,string[])
2f54bf6e => isOwner(address)
c41235a6 => isAuthorizedFor(address,string)
7a511001 => isAuthorizedFor(address,Permission)
f2fde38b => transferOwnership(address)
06fbdcd8 => getPermissionNameToIndex(string)
e75cae79 => getPermissionUnlockTime(string)
8032eccb => isLocked(string)
971563fc => lockPermission(string,uint64)
07858b02 => unlockPermission(string)
2d48e896 => setDistributionCriteria(uint256,uint256)
14b6ca96 => setShare(address,uint256)
d0e30db0 => deposit()
ffb2c479 => process(uint256)
f0fc6bca => claimDividend()
8c21cd52 => shouldDistribute(address)

```

-----

```
cb712535 => _transferFrom(address,address,uint256)
f0774e71 => _basicTransfer(address,address,uint256)
4afa518a => checkTxLimit(address,uint256)
332402f8 => shouldTakeFee(address,address)
f1f3bca3 => getTotalFee(bool)
d806d12f => getMultipliedFee()
20cb7bce => takeFee(address,address,uint256)
bff09df1 => isSell(address)
0d5c6cea => shouldSwapBack()
6ac5eeee => swapBack()
6a6e3cbe => triggerBuyback(uint256,bool)
b210b06d => clearBuybackMultiplier()
c625e9b1 => buyTokens(uint256,address)
2375ce40 => setBuybackMultiplierSettings(uint256,uint256,uint256)
8091f3bf => launched()
01339c21 => launch()
5c85974f => setTxLimit(uint256)
f708a64f => setIsDividendExempt(address,bool)
658d4b7f => setIsFeeExempt(address,bool)
f84ba65d => setIsTxLimitExempt(address,bool)
86f6c3c1 => setFees(uint256,uint256,uint256,uint256,uint256,uint256)
a4b45c00 => setFeeReceivers(address,address)
df20fd49 => setSwapBackSettings(bool,uint256)
201e7991 => setTargetLiquidity(uint256,uint256)
9d1944f5 => setDistributorSettings(uint256)
2b112e49 => getCirculatingSupply()
d51ed1c8 => getLiquidityBacking(uint256)
1161ae39 => isOverLiquified(uint256,uint256)
c2b7bbb6 => addPair(address)
0093dc14 => removeLastPair()
f3a54f2c => setFeesOnNormalTransfers(bool)
39e67c8a => setLaunchedAt(uint256)
fae36986 => setAllowedAddress(address,bool)
42966c68 => burn(uint256)
8ba4cc3c => airdrop(address,uint256)
bfa51df9 => isAirdropped(address)
5cd8c072 => setBlackListed(address,bool)
62898eb8 => _nonReentrantBefore()
c7443eb2 => _nonReentrantAfter()
119df25f => _msgSender()
8b49d47e => _msgData()
8da5cb5b => owner()
f2fde38b => transferOwnership(address)
d29d44ee => _transferOwnership(address)
18160ddd => totalSupply()
70a08231 => balanceOf(address)
a9059cbb => transfer(address,uint256)
dd62ed3e => allowance(address,address)
095ea7b3 => approve(address,uint256)
20b57614 => isAirdropped(address)

```
```
bff09df1 => isSell(address)
0d5c6cea => shouldSwapBack()
6ac5eeee => swapBack()
6a6e3cbe => triggerBuyback(uint256,bool)
b210b06d => clearBuybackMultiplier()
c625e9b1 => buyTokens(uint256,address)
2375ce40 => setBuybackMultiplierSettings(uint256,uint256,uint256)
8091f3bf => launched()
01339c21 => launch()
5c85974f => setTxLimit(uint256)
f708a64f => setIsDividendExempt(address,bool)
658d4b7f => setIsFeeExempt(address,bool)
f84ba65d => setIsTxLimitExempt(address,bool)
86f6c3c1 => setFees(uint256,uint256,uint256,uint256,uint256,uint256)
a4b45c00 => setFeeReceivers(address,address)
df20fd49 => setSwapBackSettings(bool,uint256)
201e7991 => setTargetLiquidity(uint256,uint256)
9d1944f5 => setDistributorSettings(uint256)
2b112e49 => getCirculatingSupply()
d51ed1c8 => getLiquidityBacking(uint256)
1161ae39 => isOverLiquified(uint256,uint256)
c2b7bbb6 => addPair(address)
0093dc14 => removeLastPair()
f3a54f2c => setFeesOnNormalTransfers(bool)
39e67c8a => setLaunchedAt(uint256)
fae36986 => setAllowedAddress(address,bool)
42966c68 => burn(uint256)
8ba4cc3c => airdrop(address,uint256)
bfa51df9 => isAirdropped(address)
5cd8c072 => setBlackListed(address,bool)
62898eb8 => _nonReentrantBefore()
c7443eb2 => _nonReentrantAfter()
119df25f => _msgSender()
8b49d47e => _msgData()
8da5cb5b => owner()
f2fde38b => transferOwnership(address)
d29d44ee => _transferOwnership(address)

```

-----

```
23b872dd => transferFrom(address,address,uint256)
313ce567 => decimals()
66168bd7 => depositTokens(address,uint256)
06b091f9 => withdrawTokens(address,uint256)
44a0d68a => setCost(uint256)
144fa6d7 => setToken(address)
dabd2719 => setDiscount(uint256)
0924068e => setStartandStopTime(uint32,uint32)
1fe9eabc => setMin(uint256)
1fe9eabc => setMax(uint256)
3ccfd60b => withdraw()
9d76ea58 => tokenAddress()
887d0a12 => availableForSaleTokenAmount()
0dda4650 => totalBoughtByUserTokenAmount(address)
962f05e4 => totalSoldTokenAmount()
704261e1 => tokenCostBNB()
9a46e66f => totalBNBRaisedSoFar()
b3fa9f24 => discountPercentage()
54761b8d => maxBuyableTokenAmount()
c828371e => getStartTime()
4af899a2 => getStopTime()
d96a094a => buy(uint256)
c45a0155 => factory()
ad5c4648 => WETH()
e8e33700 => addLiquidity(address,address,uint256,uint256,uint256,uint256,address,uint256)
f305d719 => addLiquidityETH(address,uint256,uint256,uint256,address,uint256)
baa2abde => removeLiquidity(address,address,uint256,uint256,uint256,address,uint256)
02751cec => removeLiquidityETH(address,uint256,uint256,uint256,address,uint256)
2195995c => 
removeLiquidityWithPermit(address,address,uint256,uint256,uint256,address,uint256,bool,uint8,bytes3
2,bytes32)
ded9382a => 
removeLiquidityETHWithPermit(address,uint256,uint256,uint256,address,uint256,bool,uint8,bytes32,byt
es32)
38ed1739 => swapExactTokensForTokens(uint256,uint256,address[],address,uint256)
8803dbee => swapTokensForExactTokens(uint256,uint256,address[],address,uint256)
7ff36ab5 => swapExactETHForTokens(uint256,address[],address,uint256)
4a25d94a => swapTokensForExactETH(uint256,uint256,address[],address,uint256)
18cbafe5 => swapExactTokensForETH(uint256,uint256,address[],address,uint256)
fb3bdb41 => swapETHForExactTokens(uint256,address[],address,uint256)
ad615dec => quote(uint256,uint256,uint256)
054d50d4 => getAmountOut(uint256,uint256,uint256)
85f8c259 => getAmountIn(uint256,uint256,uint256)
d06ca61f => getAmountsOut(uint256,address[])
1f00ca74 => getAmountsIn(uint256,address[])
af2979eb => 
removeLiquidityETHSupportingFeeOnTransferTokens(address,uint256,uint256,uint256,address,uint256)
5b0d5984 => 
removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address,uint256,uint256,uint256,address,u
int256,bool,uint8,bytes32,bytes32)

```
```
0924068e => setStartandStopTime(uint32,uint32)
1fe9eabc => setMin(uint256)
1fe9eabc => setMax(uint256)
3ccfd60b => withdraw()
9d76ea58 => tokenAddress()
887d0a12 => availableForSaleTokenAmount()
0dda4650 => totalBoughtByUserTokenAmount(address)
962f05e4 => totalSoldTokenAmount()
704261e1 => tokenCostBNB()
9a46e66f => totalBNBRaisedSoFar()
b3fa9f24 => discountPercentage()
54761b8d => maxBuyableTokenAmount()
c828371e => getStartTime()
4af899a2 => getStopTime()
d96a094a => buy(uint256)
c45a0155 => factory()
ad5c4648 => WETH()
e8e33700 => addLiquidity(address,address,uint256,uint256,uint256,uint256,address,uint256)
f305d719 => addLiquidityETH(address,uint256,uint256,uint256,address,uint256)
baa2abde => removeLiquidity(address,address,uint256,uint256,uint256,address,uint256)
02751cec => removeLiquidityETH(address,uint256,uint256,uint256,address,uint256)
2195995c => 
removeLiquidityWithPermit(address,address,uint256,uint256,uint256,address,uint256,bool,uint8,bytes3
2,bytes32)
ded9382a => 
removeLiquidityETHWithPermit(address,uint256,uint256,uint256,address,uint256,bool,uint8,bytes32,byt
38ed1739 => swapExactTokensForTokens(uint256,uint256,address[],address,uint256)
8803dbee => swapTokensForExactTokens(uint256,uint256,address[],address,uint256)
7ff36ab5 => swapExactETHForTokens(uint256,address[],address,uint256)
4a25d94a => swapTokensForExactETH(uint256,uint256,address[],address,uint256)
18cbafe5 => swapExactTokensForETH(uint256,uint256,address[],address,uint256)
fb3bdb41 => swapETHForExactTokens(uint256,address[],address,uint256)
ad615dec => quote(uint256,uint256,uint256)
054d50d4 => getAmountOut(uint256,uint256,uint256)
85f8c259 => getAmountIn(uint256,uint256,uint256)
d06ca61f => getAmountsOut(uint256,address[])

```

-----

```
5c11d795 => 
swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)
b6f9de95 => swapExactETHForTokensSupportingFeeOnTransferTokens(uint256,address[],address,uint256)
791ac947 => 
swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)
e6a43905 => getPair(address,address)
06fdde03 => name()
95d89b41 => symbol()
3644e515 => DOMAIN_SEPARATOR()
30adf81f => PERMIT_TYPEHASH()
7ecebe00 => nonces(address)
d505accf => permit(address,address,uint256,uint256,uint8,bytes32,bytes32)
ba9a7a56 => MINIMUM_LIQUIDITY()
0dfe1681 => token0()
d21220a7 => token1()
0902f1ac => getReserves()
5909c0d5 => price0CumulativeLast()
5a3d5493 => price1CumulativeLast()
7464fc3d => kLast()
6a627842 => mint(address)
89afcb44 => burn(address)
022c0d9f => swap(uint256,uint256,address,bytes)
bc25cf77 => skim(address)
fff6cae9 => sync()
485cc955 => initialize(address,address)
9dc29fac => burn(address,uint256)
d0e30db0 => deposit()
2e1a7d4d => withdraw(uint256)
077e6334 => endLock()
828047a5 => extendLockTime(uint256)
1d111d13 => withdrawBNB()
49df728c => withdrawTokens(address)
adb4fa84 => shadowStrike()
5651d706 => shadowBurst(uint256)
235d1019 => getLPOwnershipPercent()
72c5eaec => getLiquidTokens()
e3443876 => getLiquidPercent()
e528777c => getRemoveAmountForBuyAndBurnExcess()
0babc7d7 => getRemoveAmountForBuyAndBurnExcessAmount(uint256)
51c6590a => addLiquidity(uint256)
c0a4d64d => getLockTime()

```
```
95d89b41 => symbol()
3644e515 => DOMAIN_SEPARATOR()
30adf81f => PERMIT_TYPEHASH()
7ecebe00 => nonces(address)
d505accf => permit(address,address,uint256,uint256,uint8,bytes32,bytes32)
ba9a7a56 => MINIMUM_LIQUIDITY()
0dfe1681 => token0()
d21220a7 => token1()
0902f1ac => getReserves()
5909c0d5 => price0CumulativeLast()
5a3d5493 => price1CumulativeLast()
7464fc3d => kLast()
6a627842 => mint(address)
89afcb44 => burn(address)
022c0d9f => swap(uint256,uint256,address,bytes)
bc25cf77 => skim(address)
fff6cae9 => sync()
485cc955 => initialize(address,address)
9dc29fac => burn(address,uint256)
d0e30db0 => deposit()
2e1a7d4d => withdraw(uint256)
077e6334 => endLock()
828047a5 => extendLockTime(uint256)
1d111d13 => withdrawBNB()
49df728c => withdrawTokens(address)
adb4fa84 => shadowStrike()
5651d706 => shadowBurst(uint256)
235d1019 => getLPOwnershipPercent()
72c5eaec => getLiquidTokens()
e3443876 => getLiquidPercent()
e528777c => getRemoveAmountForBuyAndBurnExcess()
0babc7d7 => getRemoveAmountForBuyAndBurnExcessAmount(uint256)
51c6590a => addLiquidity(uint256)
c0a4d64d => getLockTime()

```

-----

### Inheritance Graph


-----

## Manual Analysis

#### Function Description Available Status

 provides information about the total token
 Total Supply Yes Passed
 supply

 provides account balance of the owner's
 Balance Of Yes Passed
 account

 executes transfers of a specified number of
 Transfer Yes Passed
 tokens to a specified address

 allow a spender to withdraw a set number of
 Approve Yes Passed
 tokens from a specified account

 returns a set number of tokens from a spender to
 Allowance Yes Passed
 the owner

 is an action in which the project buys back its

 Buy Back tokens from the existing holders usually at a Yes Passed

 market price

 executes transfers of a specified number of
 Burn Yes Passed
 tokens to a burn address

 executes the creation of a specified number of
 Mint NA NA
 tokens and adds it to the total supply

 circulating token supply adjusts (increases or

 Rebase decreases) automatically according to a token's NA NA

 price fluctuations

 executes transfers of a specified dividend token
 Dividend Yes Passed
 to a specified address

 locks permitted access to all or some function
 Lock Yes Passed
 modules of the smart contract


#### Total Supply Yes Passed
 supply

 provides account balance of the owner's
 Balance Of Yes Passed
 account

 executes transfers of a specified number of
 Transfer Yes Passed
 tokens to a specified address

 allow a spender to withdraw a set number of
 Approve Yes Passed
 tokens from a specified account

 returns a set number of tokens from a spender to
 Allowance Yes Passed
 the owner

 is an action in which the project buys back its

 Buy Back tokens from the existing holders usually at a Yes Passed

 market price

 executes transfers of a specified number of
 Yes Passed
 tokens to a burn address

 executes the creation of a specified number of
 NA NA
 tokens and adds it to the total supply

 circulating token supply adjusts (increases or

 Rebase decreases) automatically according to a token's NA NA

 price fluctuations

 executes transfers of a specified dividend token


-----

#### Function Description Tested Verdict

 stops specified wallets from interacting with the
 Blacklist Yes ! Low
 smart contract function modules

 executes transfers of a specified number of
 Airdrop Yes Passed
 tokens to a specified address

 a non-whitelisted wallet can only transfer a
 Max Transaction Yes Passed
 specified number of tokens

 executes fee collection from swap events and/or
 Contract Fees Yes Passed
 transfer events

 executes transfer of contract ownership to a
 Transfer Ownership Yes Passed
 specified wallet

 Renounce executes transfer of contract ownership to a
 Yes Passed
 Ownership dead address


#### executes transfers of a specified number of
 Airdrop Yes Passed
 tokens to a specified address

 a non-whitelisted wallet can only transfer a
 Max Transaction Yes Passed
 specified number of tokens

 executes fee collection from swap events and/or
 Contract Fees Yes Passed
 transfer events

 executes transfer of contract ownership to a
 Transfer Ownership Yes Passed
 specified wallet

 Renounce executes transfer of contract ownership to a
 Yes Passed
 Ownership dead address


-----

### Notable Information 📝

#### v Token contract authorizes wallets to modify some contract privileged functions. When

 ownership is transferred, previous authorizations should be voided. There’s an elevated risk

 of out-of-gas, and potential resource exhaustion errors with multi wallet calls.
```
  constructor(address owner_) {
    owner = owner_;
     for (uint256 i; i < NUM_PERMISSIONS; i++) {
      authorizations[owner_][i] = true;
  function authorizeFor(address adr, string memory permissionName) public
authorizedFor(Permission.Authorize) {
    uint256 permIndex = permissionNameToIndex[permissionName];
    authorizations[adr][permIndex] = true;
  function authorizeForMultiplePermissions(address adr, string[] calldata permissionNames) public
authorizedFor(Permission.Authorize) {
     for (uint256 i; i < permissionNames.length; i++) {
      uint256 permIndex = permissionNameToIndex[permissionNames[i]];
      authorizations[adr][permIndex] = true;
  function transferOwnership(address payable adr) public onlyOwner {
    address oldOwner = owner;
    owner = adr;
     for (uint256 i; i < NUM_PERMISSIONS; i++) {
      authorizations[oldOwner][i] = false;
      authorizations[owner][i] = true;

 v Token contract authorized role can change buyback multiplier settings.
  function triggerBuyback(uint256 amount, bool triggerBuybackMultiplier) external
authorizedFor(Permission.Buyback) {
     // buyTokens(amount, DEAD);
    burn(msg.sender, amount);
     if(triggerBuybackMultiplier){
      buybackMultiplierTriggeredAt = block.timestamp;

 v In presale contract, function buy() is protected against re-entrancy.

 v In liquidity lock contract, function addLiquidity() is protected against re-entrancy.

```

#### of out-of-gas, and potential resource exhaustion errors with multi wallet calls.
```
constructor(address owner_) {
    owner = owner_;
  for (uint256 i; i < NUM_PERMISSIONS; i++) {
      authorizations[owner_][i] = true;
function authorizeFor(address adr, string memory permissionName) public
authorizedFor(Permission.Authorize) {
    uint256 permIndex = permissionNameToIndex[permissionName];
    authorizations[adr][permIndex] = true;
function authorizeForMultiplePermissions(address adr, string[] calldata permissionNames) public
authorizedFor(Permission.Authorize) {
  for (uint256 i; i < permissionNames.length; i++) {
      uint256 permIndex = permissionNameToIndex[permissionNames[i]];
      authorizations[adr][permIndex] = true;
function transferOwnership(address payable adr) public onlyOwner {
    address oldOwner = owner;
    owner = adr;
  for (uint256 i; i < NUM_PERMISSIONS; i++) {
      authorizations[oldOwner][i] = false;
      authorizations[owner][i] = true;

 v Token contract authorized role can change buyback multiplier settings.
function triggerBuyback(uint256 amount, bool triggerBuybackMultiplier) external
authorizedFor(Permission.Buyback) {
  // buyTokens(amount, DEAD);
    burn(msg.sender, amount);
  if(triggerBuybackMultiplier){
      buybackMultiplierTriggeredAt = block.timestamp;

```

### 📝


-----

#### v Presale contract owner can set token to sell, set sell cost, and set sell discount.
```
  function setCost(uint256 _cost) public onlyOwner {
    tokenCost = _cost;
  function setToken(address _tokenAddress) public onlyOwner {
     require(address(token) != _tokenAddress, "Already set!");
    token = IShadowFiToken(_tokenAddress);
  function setDiscount(uint256 _discountPercent) public onlyOwner {
     require(
      _discountPercent > 1 && _discountPercent < 1001,

```
```
       "Invalid percent is provided."

```

#### v Presale contract owner can set min and max token buyable amount.
```
  function setMin(uint256 _minAmount) public onlyOwner {
    minAmount = _minAmount;
  function setMax(uint256 _maxAmount) public onlyOwner {
    maxAmount = _maxAmount;

 v Liquidity lock contract owner can add liquidity.
  function addLiquidity(uint256 _amountToken) external payable onlyOwner {
     require(!lockEnded, "Contract is locked.");
     require(_amountToken > 0, "Invalid parameter is provided.");

```
```
     require(msg.value > 0, "You should fund this contract with BNB.");

```

#### v Liquidity lock contract owner can end lock once the unlock time is reached.
```
  function endLock() public onlyOwner {
     require(!lockEnded, "You already claimed all LP tokens.");
     require(block.timestamp >= lockTime, "LP tokens are still locked.");

 v Liquidity lock contract utilizes shadowStrike(), and shadowBurst(). Amount of ShadowFi

 tokens in liquidity is at least 8% of the total supply. 
  function shadowStrike() public onlyOwner {
     require(liquidPercent > 800, "The amount of ShadowFi tokens in liquidity should be 8%+ of
the totalSupply.");
  function shadowBurst(uint256 percent) public onlyOwner {
     require(percent >= 1 && percent <= 9200, "Invalid parameter is provided");

```
```
    token = IShadowFiToken(_tokenAddress);
function setDiscount(uint256 _discountPercent) public onlyOwner {
  require(
      _discountPercent > 1 && _discountPercent < 1001,
     "Invalid percent is provided."

#### v Presale contract owner can set min and max token buyable amount.
function setMin(uint256 _minAmount) public onlyOwner {
    minAmount = _minAmount;
function setMax(uint256 _maxAmount) public onlyOwner {
    maxAmount = _maxAmount;

 v Liquidity lock contract owner can add liquidity.
function addLiquidity(uint256 _amountToken) external payable onlyOwner {
  require(!lockEnded, "Contract is locked.");
  require(_amountToken > 0, "Invalid parameter is provided.");
  require(msg.value > 0, "You should fund this contract with BNB.");

 v Liquidity lock contract owner can end lock once the unlock time is reached.
function endLock() public onlyOwner {
  require(!lockEnded, "You already claimed all LP tokens.");
  require(block.timestamp >= lockTime, "LP tokens are still locked.");

 v Liquidity lock contract utilizes shadowStrike(), and shadowBurst(). Amount of ShadowFi

 tokens in liquidity is at least 8% of the total supply. 

```

-----

```
     require(liquidPercent - percent >= 800, "The amount compared to liquidity tokens should be
less than 8% of the totalSupply.");

#### v Token Smart contract utilizes safemath function to avoid common smart contract

 vulnerabilities.
  string private _name = "ShadowFiToken";
  library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
     require(c >= a, "SafeMath: addition overflow");
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
     return sub(a, b, "SafeMath: subtraction overflow");
    uint256 c = a * b;
     require(c / a == b, "SafeMath: multiplication overflow");
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     return div(a, b, "SafeMath: division by zero");
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
     return mod(a, b, "SafeMath: modulo by zero");

 v Smart contracts call receive() for fallbacks. It is executed on a call to the contract with

 empty call data. Make sure the contract can receive token through a regular transaction,

 and does not throw an exception.
     receive() external payable {}
     fallback() external payable {}

 v Token contract owner can airdrop tokens to specified wallets. 
  function airdrop(address _user, uint256 _amount) external onlyOwner {
    _transferFrom(msg.sender, _user, _amount);
    airdropped[_user] = true;

 v Token contract owner can blacklist certain wallets from interacting with the contract

 function modules.
  function setBlackListed(address user, bool flag) external onlyOwner {
    blackList[user] = flag;

```
```
  string private _name = "ShadowFiToken";
library SafeMath {
function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
  require(c >= a, "SafeMath: addition overflow");
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
  return sub(a, b, "SafeMath: subtraction overflow");
    uint256 c = a * b;
  require(c / a == b, "SafeMath: multiplication overflow");
function div(uint256 a, uint256 b) internal pure returns (uint256) {
  return div(a, b, "SafeMath: division by zero");
function mod(uint256 a, uint256 b) internal pure returns (uint256) {
  return mod(a, b, "SafeMath: modulo by zero");

#### v Smart contracts call receive() for fallbacks. It is executed on a call to the contract with

 empty call data. Make sure the contract can receive token through a regular transaction,

 and does not throw an exception.
  receive() external payable {}
  fallback() external payable {}

 v Token contract owner can airdrop tokens to specified wallets. 
function airdrop(address _user, uint256 _amount) external onlyOwner {
    _transferFrom(msg.sender, _user, _amount);
    airdropped[_user] = true;

 v Token contract owner can blacklist certain wallets from interacting with the contract

 function modules.

```

-----

#### v Token contract authorized role can change transaction fees. Maximum fee limits are set to

 allow the value change within the set parameters.
```
  function setFees(uint256 _liquidityFee, uint256 _buybackFee, uint256 _reflectionFee, uint256
_marketingFee, uint256 _feeDenominator, uint256 _totalSellFee) external
authorizedFor(Permission.AdjustContractVariables) {
    totalBuyFee = _liquidityFee.add(_buybackFee).add(_reflectionFee).add(_marketingFee);
     require(totalBuyFee <= feeDenominator / 10, "Buy fee too high");
     require(totalSellFee <= feeDenominator / 5, "Sell fee too high");
  uint256 liquidityFee = 200;
  uint256 buybackFee = 0;
  uint256 reflectionFee = 600;
  uint256 marketingFee = 100;
  uint256 totalBuyFee = 900;
  uint256 totalSellFee = 1400;
  uint256 feeDenominator = 10000;

 v Token contract authorized role can change max transaction limit. Minimum limit is set to

 allow the value change within the set parameters.
  function setTxLimit(uint256 amount) external authorizedFor(Permission.AdjustContractVariables) 
     require(amount >= _maxSupply / 2000);

 v Token contract function addLiquidity() should send auto liquidity to an inaccessible

 address. Token contract sends LP tokens to autoLiquidityReceiver.
       if(amountToLiquify > 0){
          try router.addLiquidityETH{ value: amountBNBLiquidity }(
          address(this),
          amountToLiquify,
            0,
            0,
          autoLiquidityReceiver,
            block.timestamp
    autoLiquidityReceiver = owner_;

 v Token contract has an informational severity issue which may or may not create any

 functional vulnerability.

 “Irrelevant Code”

```
```
_marketingFee, uint256 _feeDenominator, uint256 _totalSellFee) external
authorizedFor(Permission.AdjustContractVariables) {
    totalBuyFee = _liquidityFee.add(_buybackFee).add(_reflectionFee).add(_marketingFee);
  require(totalBuyFee <= feeDenominator / 10, "Buy fee too high");
  require(totalSellFee <= feeDenominator / 5, "Sell fee too high");
  uint256 liquidityFee = 200;
  uint256 buybackFee = 0;
  uint256 reflectionFee = 600;
  uint256 marketingFee = 100;
  uint256 totalBuyFee = 900;
  uint256 totalSellFee = 1400;
  uint256 feeDenominator = 10000;

#### v Token contract authorized role can change max transaction limit. Minimum limit is set to

 allow the value change within the set parameters.
function setTxLimit(uint256 amount) external authorizedFor(Permission.AdjustContractVariables) 
  require(amount >= _maxSupply / 2000);

 v Token contract function addLiquidity() should send auto liquidity to an inaccessible

 address. Token contract sends LP tokens to autoLiquidityReceiver.
     if(amountToLiquify > 0){
       try router.addLiquidityETH{ value: amountBNBLiquidity }(
          address(this),
          amountToLiquify,
          0,
          0,
          autoLiquidityReceiver,
          block.timestamp
    autoLiquidityReceiver = owner_;

```

-----

#### v Token contract has an informational severity issue which may or may not create any

 functional vulnerability.

 “Unknown Externally Owned Accounts”

 v Smart contracts have informational severity issue which may or may not create any

 functional vulnerability.

 “Expected pragma, import directive or contract/interface/library definition”

 v Smart contracts have low severity issue which may or may not create any functional

 vulnerability.

 “Utilization of block.timestamp”


#### functional vulnerability.

 “Expected pragma, import directive or contract/interface/library definition”

 v Smart contracts have low severity issue which may or may not create any functional

 vulnerability.

 “Utilization of block.timestamp”


-----

## 