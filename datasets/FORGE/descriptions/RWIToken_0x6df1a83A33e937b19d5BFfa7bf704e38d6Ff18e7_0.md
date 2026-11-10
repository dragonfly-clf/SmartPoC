RWI Token’s Centralization Status

v RWI Token’s smart contract has an active ownership.


-----

## Static Analysis

**Symbol** **Meaning**

🛑 Function can modify state

💵 Function is payable

🔒 Function is locked

🔐 Function can be accessed

❗ Important functionality
```
| **SafeMath** | Library | |||
| └ | mul | Internal 🔒 |  | |
| └ | div | Internal 🔒 |  | |
| └ | sub | Internal 🔒 |  | |
| └ | add | Internal 🔒 |  | |

```

🛑


🔒


❗

```
||||||

```

💵

```
| **Ownable** | Implementation | |||
| └ | transferOwnership | Public ❗ | 🛑 | onlyOwner |
||||||
| **Pausable** | Implementation | Ownable |||
| └ | pause | Public ❗ | 🛑 | onlyOwner whenNotPaused |
| └ | unpause | Public ❗ | 🛑 | onlyOwner whenPaused |
||||||
| **ERC20Basic** | Implementation | |||
| └ | balanceOf | Public ❗ |  |NO❗ |
| └ | transfer | Public ❗ | 🛑 |NO❗ |
||||||
| **ERC20** | Implementation | ERC20Basic |||
| └ | allowance | Public ❗ |  |NO❗ |
| └ | transferFrom | Public ❗ | 🛑 |NO❗ |
| └ | approve | Public ❗ | 🛑 |NO❗ |

```

🔐

```
||||||

```
```
| **StandardToken** | Implementation | ERC20 |||
| └ | transfer | Public ❗ | 🛑 |NO❗ |
| └ | balanceOf | Public ❗ |  |NO❗ |
| └ | transferFrom | Public ❗ | 🛑 |NO❗ |
| └ | approve | Public ❗ | 🛑 |NO❗ |
| └ | allowance | Public ❗ |  |NO❗ |
| └ | increaseApproval | Public ❗ | 🛑 |NO❗ |
| └ | decreaseApproval | Public ❗ | 🛑 |NO❗ |
| └ | _blackList | Internal 🔒 | 🛑 | |

```

Function is payable

Function is locked

Function can be accessed

Important functionality
```
**SafeMath** | Library | |||
| └ | mul | Internal 🔒 |  | |
| └ | div | Internal 🔒 |  | |
| └ | sub | Internal 🔒 |  | |
| └ | add | Internal 🔒 |  | |
**Ownable** | Implementation | |||
| └ | transferOwnership | Public ❗ | 🛑 | onlyOwner |
**Pausable** | Implementation | Ownable |||
| └ | pause | Public ❗ | 🛑 | onlyOwner whenNotPaused |
| └ | unpause | Public ❗ | 🛑 | onlyOwner whenPaused |
**ERC20Basic** | Implementation | |||
| └ | balanceOf | Public ❗ |  |NO❗ |
| └ | transfer | Public ❗ | 🛑 |NO❗ |
**ERC20** | Implementation | ERC20Basic |||
| └ | allowance | Public ❗ |  |NO❗ |
| └ | transferFrom | Public ❗ | 🛑 |NO❗ |
| └ | approve | Public ❗ | 🛑 |NO❗ |
**StandardToken** | Implementation | ERC20 |||
| └ | transfer | Public ❗ | 🛑 |NO❗ |
| └ | balanceOf | Public ❗ |  |NO❗ |

```

❗


❗


❗


❗


🛑


❗


❗


🛑


-----

```
||||||
| **PausableToken** | Implementation | StandardToken, Pausable |||
| └ | transfer | Public ❗ | 🛑 | whenNotPaused |
| └ | transferFrom | Public ❗ | 🛑 | whenNotPaused |
| └ | approve | Public ❗ | 🛑 | whenNotPaused |
| └ | increaseApproval | Public ❗ | 🛑 | whenNotPaused |
| └ | decreaseApproval | Public ❗ | 🛑 | whenNotPaused |
| └ | blackListAddress | Public ❗ | 🛑 | whenNotPaused onlyOwner |
||||||
| **RWItoken** | Implementation | PausableToken |||
| └ | <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | burn | Public ❗ | 🛑 |NO❗ |
| └ | _burn | Internal 🔒 | 🛑 | |
| └ | mint | Public ❗ | 🛑 | onlyOwner |

```
```
| └ | blackListAddress | Public ❗ | 🛑 | whenNotPaused onlyOwner |
**RWItoken** | Implementation | PausableToken |||
 <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | burn | Public ❗ | 🛑 |NO❗ |
| └ | _burn | Internal 🔒 | 🛑 | |
| └ | mint | Public ❗ | 🛑 | onlyOwner |

```

❗


❗


❗


❗


❗


-----

## Software Analysis

### Function Signatures
```
66188463 => decreaseApproval(address,uint256)
c8a4ac9c => mul(uint256,uint256)
a391c15b => div(uint256,uint256)
b67d77c5 => sub(uint256,uint256)
771602f7 => add(uint256,uint256)
f2fde38b => transferOwnership(address)
8456cb59 => pause()
3f4ba83a => unpause()
70a08231 => balanceOf(address)
a9059cbb => transfer(address,uint256)
dd62ed3e => allowance(address,address)
23b872dd => transferFrom(address,address,uint256)
095ea7b3 => approve(address,uint256)
d73dd623 => increaseApproval(address,uint256)
6dbdc508 => _blackList(address,bool)
794be707 => blackListAddress(address,bool)
42966c68 => burn(uint256)
6161eb18 => _burn(address,uint256)
40c10f19 => mint(address,uint256)

```
```
a391c15b => div(uint256,uint256)
b67d77c5 => sub(uint256,uint256)
771602f7 => add(uint256,uint256)
f2fde38b => transferOwnership(address)
8456cb59 => pause()
3f4ba83a => unpause()
70a08231 => balanceOf(address)
a9059cbb => transfer(address,uint256)
dd62ed3e => allowance(address,address)
23b872dd => transferFrom(address,address,uint256)
095ea7b3 => approve(address,uint256)
d73dd623 => increaseApproval(address,uint256)
6dbdc508 => _blackList(address,bool)
794be707 => blackListAddress(address,bool)
42966c68 => burn(uint256)
6161eb18 => _burn(address,uint256)
40c10f19 => mint(address,uint256)

```

-----

### Inheritance Graph


-----

## Manual Analysis

**Function** **Description** **Available** **Status**

provides information about the total token

**Total Supply** Yes **Passed**

supply

provides account balance of the owner's

**Balance Of** Yes **Passed**

account

executes transfers of a specified number of

**Transfer** Yes **Passed**

tokens to a specified address

allow a spender to withdraw a set number of

**Approve** Yes **Passed**

tokens from a specified account

returns a set number of tokens from a spender

**Allowance** Yes **Passed**

to the owner

executes transfers of a specified number of

**Burn** Yes **Passed**

tokens to a burn address

executes the creation of a specified number of

**Mint** Yes **! Low**

tokens and adds it to the total supply

stops specified wallets from interacting with the

**Blacklist** Yes **! Low**

smart contract function modules

executes transfer of contract ownership to a

**Transfer Ownership** Yes **Passed**

specified wallet

**Renounce** executes transfer of contract ownership to a

Yes **Passed**

**Ownership** dead address


**Total Supply** Yes **Passed**

supply

provides account balance of the owner's

**Balance Of** Yes **Passed**

account

executes transfers of a specified number of

**Transfer** Yes **Passed**

tokens to a specified address

allow a spender to withdraw a set number of

**Approve** Yes **Passed**

tokens from a specified account

returns a set number of tokens from a spender

**Allowance** Yes **Passed**

to the owner

executes transfers of a specified number of

Yes **Passed**

tokens to a burn address

executes the creation of a specified number of

Yes **! Low**

tokens and adds it to the total supply

stops specified wallets from interacting with the

**Blacklist** Yes **! Low**

smart contract function modules

executes transfer of contract ownership to a

**Transfer Ownership** Yes **Passed**

specified wallet

**Renounce** executes transfer of contract ownership to a

Yes **Passed**

**Ownership** dead address


-----

### 