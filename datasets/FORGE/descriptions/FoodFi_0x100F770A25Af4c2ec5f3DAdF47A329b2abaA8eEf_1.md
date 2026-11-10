Risk Classification

Smart contracts are generally designed to manipulate and hold funds denominated in ETH/BNB.

This makes them very tempting attack targets, as a successful attack may allow the attacker to

directly steal funds from the contract. Below are the typical risk levels of a smart contract:

**Vulnerable: A contract is vulnerable if it has been flagged by a static analysis tool as such. As we**

will see later, this means that some contracts may be vulnerable because of a false positive.

**Exploitable: A contract is exploitable if it is vulnerable and the vulnerability could be exploited by an**

external attacker. For example, if the “vulnerability” flagged by a tool is in a function that requires

owning the contract, it would be vulnerable but not exploitable.

**Exploited: A contract is exploited if it received a transaction on the main network which triggered**

one of its vulnerabilities. Therefore, a contract can be vulnerable or even exploitable without having

been exploited.

**Risk severity** **Meaning**

This level vulnerabilities could be exploited easily and can lead to asset loss,

**! High**

data loss, asset, or data manipulation. They should be fixed right away.

This level vulnerabilities are hard to exploit but very important to fix, they carry


**! Medium**

**! Low**

**! Informational**


an elevated risk of smart contract manipulation, which can lead to high-risk

severity

This level vulnerabilities should be fixed, as they carry an inherent risk of future

exploits, and hacks which may or may not impact the smart contract execution.

This level vulnerabilities can be ignored. They are code style violations and

informational statements in the code. They may not affect the smart contract

execution


directly steal funds from the contract. Below are the typical risk levels of a smart contract:

**Vulnerable: A contract is vulnerable if it has been flagged by a static analysis tool as such. As we**

will see later, this means that some contracts may be vulnerable because of a false positive.

**Exploitable: A contract is exploitable if it is vulnerable and the vulnerability could be exploited by an**

external attacker. For example, if the “vulnerability” flagged by a tool is in a function that requires

owning the contract, it would be vulnerable but not exploitable.

**Exploited: A contract is exploited if it received a transaction on the main network which triggered**

one of its vulnerabilities. Therefore, a contract can be vulnerable or even exploitable without having

been exploited.

**Risk severity** **Meaning**

This level vulnerabilities could be exploited easily and can lead to asset loss,

**! High**

data loss, asset, or data manipulation. They should be fixed right away.

This level vulnerabilities are hard to exploit but very important to fix, they carry

**! Medium** an elevated risk of smart contract manipulation, which can lead to high-risk

severity

This level vulnerabilities should be fixed, as they carry an inherent risk of future

exploits, and hacks which may or may not impact the smart contract execution.


-----

# Centralization Risk

Centralization risk is the most common cause of decentralized finance hacks. When a smart

contract has an active contract ownership, the risk related to centralization is elevated. There are

some well-intended reasons to be an active contract owner, such as:

v Contract owner can be granted the power to pause() or lock() the contract in case of an

external attack.

v Contract owner can use functions like, include(), and exclude() to add or remove wallets

from fees, swap checks, and transaction limits. This is useful to run a presale, and to list on

an exchange.

Authorizing a full centralized power to a single body can be dangerous. Unfortunately, centralization

related risks are higher than common smart contract vulnerabilities. Centralization of ownership

creates a risk of rug pull scams, where owners cash out tokens in such quantities that they become

valueless. **Most important question to ask here is, how to mitigate centralization risk? Here’s**

InterFi’s recommendation to lower the risks related to centralization hacks:

v Smart contract owner’s private key must be carefully secured to avoid any potential hack.

v Smart contract ownership should be shared by multi-signature (multi-sig) wallets.

v Smart contract ownership can be locked in a contract, user voting, or community DAO can

be introduced to unlock the ownership.

## Food-Fi’s Centralization Status

v Food-Fi’s smart contract has an active ownership.


some well-intended reasons to be an active contract owner, such as:

v Contract owner can be granted the power to pause() or lock() the contract in case of an

external attack.

v Contract owner can use functions like, include(), and exclude() to add or remove wallets

from fees, swap checks, and transaction limits. This is useful to run a presale, and to list on

an exchange.

Authorizing a full centralized power to a single body can be dangerous. Unfortunately, centralization

related risks are higher than common smart contract vulnerabilities. Centralization of ownership

creates a risk of rug pull scams, where owners cash out tokens in such quantities that they become

valueless. **Most important question to ask here is, how to mitigate centralization risk?**

InterFi’s recommendation to lower the risks related to centralization hacks:

v Smart contract owner’s private key must be carefully secured to avoid any potential hack.

v Smart contract ownership should be shared by multi-signature (multi-sig) wallets.

v Smart contract ownership can be locked in a contract, user voting, or community DAO can

be introduced to unlock the ownership.

## Food-Fi’s Centralization Status

v Food-Fi’s smart contract has an active ownership.


-----

# Static Analysis

**Symbol** **Meaning**

$ Function can modify state

% Function is payable

& Function is locked

' Function can be accessed

❗ Important functionality
```
| **SafeMath** | Library | |||
| └ | tryAdd | Internal ! |  | |
| └ | trySub | Internal ! |  | |
| └ | tryMul | Internal ! |  | |
| └ | tryDiv | Internal ! |  | |
| └ | tryMod | Internal ! |  | |
| └ | add | Internal ! |  | |
| └ | sub | Internal ! |  | |
| └ | mul | Internal ! |  | |
| └ | div | Internal ! |  | |
| └ | mod | Internal ! |  | |
| └ | sub | Internal ! |  | |
| └ | div | Internal ! |  | |
| └ | mod | Internal ! |  | |
||||||
| **IDexFactory** | Interface | |||
| └ | createPair | External ❗ | # |NO❗ |
||||||
| **IDexRouter** | Interface | |||
| └ | factory | External ❗ |  |NO❗ |
| └ | WETH | External ❗ |  |NO❗ |
| └ | addLiquidityETH | External ❗ | $ |NO❗ |
| └ | swapExactETHForTokensSupportingFeeOnTransferTokens | External ❗ | $ |NO❗ |
| └ | swapExactTokensForETHSupportingFeeOnTransferTokens | External ❗ | # |NO❗ |
||||||
| **IERC20Extended** | Interface | |||
| └ | totalSupply | External ❗ |  |NO❗ |
| └ | decimals | External ❗ |  |NO❗ |
| └ | symbol | External ❗ |  |NO❗ |
| └ | name | External ❗ |  |NO❗ |
| └ | balanceOf | External ❗ |  |NO❗ |

```

Function is payable

Function is locked

Function can be accessed

Important functionality
```
**SafeMath** | Library | |||
| └ | tryAdd | Internal ! |  | |
| └ | trySub | Internal ! |  | |
| └ | tryMul | Internal ! |  | |
| └ | tryDiv | Internal ! |  | |
| └ | tryMod | Internal ! |  | |
| └ | add | Internal ! |  | |
| └ | sub | Internal ! |  | |
| └ | mul | Internal ! |  | |
| └ | div | Internal ! |  | |
| └ | mod | Internal ! |  | |
| └ | sub | Internal ! |  | |
| └ | div | Internal ! |  | |
| └ | mod | Internal ! |  | |
**IDexFactory** | Interface | |||
| └ | createPair | External ❗ | # |NO❗ |
**IDexRouter** | Interface | |||
| └ | factory | External ❗ |  |NO❗ |
| └ | WETH | External ❗ |  |NO❗ |
| └ | addLiquidityETH | External ❗ | $ |NO❗ |
| └ | swapExactETHForTokensSupportingFeeOnTransferTokens | External ❗ | $ |NO❗ |
| └ | swapExactTokensForETHSupportingFeeOnTransferTokens | External ❗ | # |NO❗ |

```

$


&


❗


❗


❗


❗


❗


❗


-----

```
| └ | transfer | External ❗ | # |NO❗ |
| └ | allowance | External ❗ |  |NO❗ |
| └ | approve | External ❗ | # |NO❗ |
| └ | transferFrom | External ❗ | # |NO❗ |
||||||
| **Auth** | Implementation | |||
| └ | <Constructor> | Public ❗ | # |NO❗ |
| └ | authorize | Public ❗ | # | onlyOwner |
| └ | unauthorize | Public ❗ | # | onlyOwner |
| └ | isOwner | Public ❗ |  |NO❗ |
| └ | isAuthorized | Public ❗ |  |NO❗ |
| └ | transferOwnership | Public ❗ | # | onlyOwner |
||||||
| **IPinkAntiBot** | Interface | |||
| └ | setTokenOwner | External ❗ | # |NO❗ |
| └ | onPreTransferCheck | External ❗ | # |NO❗ |
||||||
| **IDividendDistributor** | Interface | |||
| └ | setDistributionCriteria | External ❗ | # |NO❗ |
| └ | setShare | External ❗ | # |NO❗ |
| └ | deposit | External ❗ | $ |NO❗ |
| └ | process | External ❗ | # |NO❗ |
| └ | claimDividend | External ❗ | # |NO❗ |
| └ | getPaidEarnings | External ❗ |  |NO❗ |
| └ | getUnpaidEarnings | External ❗ |  |NO❗ |
| └ | totalDistributed | External ❗ |  |NO❗ |
||||||
| **DividendDistributor** | Implementation | IDividendDistributor |||
| └ | <Constructor> | Public ❗ | # |NO❗ |
| └ | setDistributionCriteria | External ❗ | # | onlyToken |
| └ | setShare | External ❗ | # | onlyToken |
| └ | deposit | External ❗ | $ | onlyToken |
| └ | process | External ❗ | # | onlyToken |
| └ | shouldDistribute | Internal ! |  | |
| └ | distributeDividend | Internal ! | # | |
| └ | claimDividend | External ❗ | # |NO❗ |
| └ | getPaidEarnings | Public ❗ |  |NO❗ |
| └ | getUnpaidEarnings | Public ❗ |  |NO❗ |
| └ | getCumulativeDividends | Internal ! |  | |
| └ | addShareholder | Internal ! | # | |
| └ | removeShareholder | Internal ! | # | |
||||||
| **Food_Fi_Token** | Implementation | IERC20Extended, Auth |||
| └ | <Constructor> | Public ❗ | # | Auth |
| └ | <Receive Ether> | External ❗ | $ |NO❗ |
| └ | totalSupply | External ❗ |  |NO❗ |
| └ | decimals | External ❗ |  |NO❗ |
| └ | symbol | External ❗ |  |NO❗ |
| └ | name | External ❗ |  |NO❗ |
| └ | balanceOf | Public ❗ |  |NO❗ |

```
```
| └ | authorize | Public ❗ | # | onlyOwner |
| └ | unauthorize | Public ❗ | # | onlyOwner |
| └ | isOwner | Public ❗ |  |NO❗ |
| └ | isAuthorized | Public ❗ |  |NO❗ |
| └ | transferOwnership | Public ❗ | # | onlyOwner |
**IPinkAntiBot** | Interface | |||
| └ | setTokenOwner | External ❗ | # |NO❗ |
| └ | onPreTransferCheck | External ❗ | # |NO❗ |
**IDividendDistributor** | Interface | |||
| └ | setDistributionCriteria | External ❗ | # |NO❗ |
| └ | setShare | External ❗ | # |NO❗ |
| └ | deposit | External ❗ | $ |NO❗ |
| └ | process | External ❗ | # |NO❗ |
| └ | claimDividend | External ❗ | # |NO❗ |
| └ | getPaidEarnings | External ❗ |  |NO❗ |
| └ | getUnpaidEarnings | External ❗ |  |NO❗ |
| └ | totalDistributed | External ❗ |  |NO❗ |
**DividendDistributor** | Implementation | IDividendDistributor |||
 <Constructor> | Public ❗ | # |NO❗ |
| └ | setDistributionCriteria | External ❗ | # | onlyToken |
| └ | setShare | External ❗ | # | onlyToken |
| └ | deposit | External ❗ | $ | onlyToken |
| └ | process | External ❗ | # | onlyToken |
| └ | shouldDistribute | Internal ! |  | |
| └ | distributeDividend | Internal ! | # | |
| └ | claimDividend | External ❗ | # |NO❗ |
| └ | getPaidEarnings | Public ❗ |  |NO❗ |
| └ | getUnpaidEarnings | Public ❗ |  |NO❗ |
| └ | getCumulativeDividends | Internal ! |  | |
| └ | addShareholder | Internal ! | # | |
| └ | removeShareholder | Internal ! | # | |
**Food_Fi_Token** | Implementation | IERC20Extended, Auth |||
 <Constructor> | Public ❗ | # | Auth |

```

❗


❗


❗


#


❗


❗


#


#


$


❗


❗


❗


❗


❗


❗


-----

```
| └ | allowance | External ❗ |  |NO❗ |
| └ | approve | Public ❗ | # |NO❗ |
| └ | approveMax | External ❗ | # |NO❗ |
| └ | transfer | External ❗ | # |NO❗ |
| └ | transferFrom | External ❗ | # |NO❗ |
| └ | _transferFrom | Internal ! | # | |
| └ | _basicTransfer | Internal ! | # | |
| └ | shouldTakeFee | Internal ! |  | |
| └ | takeFee | Internal ! | # | |
| └ | setBuyAccFee | Internal ! | # | |
| └ | setSellAccFee | Internal ! | # | |
| └ | shouldSwapBack | Internal ! |  | |
| └ | swapBack | Internal ! | # | swapping |
| └ | claimDividend | External ❗ | # |NO❗ |
| └ | getPaidDividend | Public ❗ |  |NO❗ |
| └ | getUnpaidDividend | External ❗ |  |NO❗ |
| └ | getTotalDistributedDividend | External ❗ |  |NO❗ |
| └ | setAntiBot | External ❗ | # | authorized |
| └ | setIsDividendExempt | External ❗ | # | authorized |
| └ | setIsFeeExempt | External ❗ | # | authorized |
| └ | setBuyFees | Public ❗ | # | authorized |
| └ | setSellFees | Public ❗ | # | authorized |
| └ | setFeeReceivers | External ❗ | # | authorized |
| └ | setSwapBackSettings | External ❗ | # | authorized |
| └ | setTargetLiquidity | External ❗ | # | authorized |
| └ | setDistributionCriteria | External ❗ | # | authorized |
| └ | setDistributorSettings | External ❗ | # | authorized |
| └ | getCirculatingSupply | Public ❗ |  |NO❗ |
| └ | getLiquidityBacking | Public ❗ |  |NO❗ |
| └ | isOverLiquified | Public ❗ |  |NO❗ |

```
```
| └ | shouldTakeFee | Internal ! |  | |
| └ | takeFee | Internal ! | # | |
| └ | setBuyAccFee | Internal ! | # | |
| └ | setSellAccFee | Internal ! | # | |
| └ | shouldSwapBack | Internal ! |  | |
| └ | swapBack | Internal ! | # | swapping |
| └ | claimDividend | External ❗ | # |NO❗ |
| └ | getPaidDividend | Public ❗ |  |NO❗ |
| └ | getUnpaidDividend | External ❗ |  |NO❗ |
| └ | getTotalDistributedDividend | External ❗ |  |NO❗ |
| └ | setAntiBot | External ❗ | # | authorized |
| └ | setIsDividendExempt | External ❗ | # | authorized |
| └ | setIsFeeExempt | External ❗ | # | authorized |
| └ | setBuyFees | Public ❗ | # | authorized |
| └ | setSellFees | Public ❗ | # | authorized |
| └ | setFeeReceivers | External ❗ | # | authorized |
| └ | setSwapBackSettings | External ❗ | # | authorized |
| └ | setTargetLiquidity | External ❗ | # | authorized |
| └ | setDistributionCriteria | External ❗ | # | authorized |
| └ | setDistributorSettings | External ❗ | # | authorized |
| └ | getCirculatingSupply | Public ❗ |  |NO❗ |
| └ | getLiquidityBacking | Public ❗ |  |NO❗ |
| └ | isOverLiquified | Public ❗ |  |NO❗ |

```

❗


❗


❗


#


❗


❗


#


!


!


-----

# Software Analysis

## 