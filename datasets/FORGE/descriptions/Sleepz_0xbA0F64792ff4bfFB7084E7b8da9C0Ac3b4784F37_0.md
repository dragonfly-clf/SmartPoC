Sleepz’s Centralization Status

v Sleepz’s smart contract has an active ownership.


-----

## Static Analysis

**Symbol** **Meaning**

🛑 Function can modify state

💵 Function is payable

🔒 Function is locked

🔐 Function can be accessed

❗ Important functionality
```
| **IDexFactory** | Interface | |||
| └ | createPair | External ❗ | 🛑 |NO❗ |
||||||
| **IDexRouter** | Interface | |||
| └ | factory | External ❗ |  |NO❗ |
| └ | WETH | External ❗ |  |NO❗ |
| └ | swapExactTokensForETH | External ❗ | 🛑 |NO❗ |
||||||
| **Ownable** | Implementation | |||
| └ | <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | transferOwnership | Public ❗ | 🛑 | onlyOwner |
| └ | owner | Internal 🔒 |  | |
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
| **BEP20** | Implementation | IBEP20, Ownable |||
| └ | <Constructor> | Public ❗ | 🛑 | Ownable |
| └ | getOwner | Public ❗ |  |NO❗ |
| └ | decimals | Public ❗ |  |NO❗ |
| └ | symbol | External ❗ |  |NO❗ |
| └ | name | External ❗ |  |NO❗ |

```

Function is payable

Function is locked

Function can be accessed

Important functionality
```
**IDexFactory** | Interface | |||
| └ | createPair | External ❗ | 🛑 |NO❗ |
**IDexRouter** | Interface | |||
| └ | factory | External ❗ |  |NO❗ |
| └ | WETH | External ❗ |  |NO❗ |
| └ | swapExactTokensForETH | External ❗ | 🛑 |NO❗ |
**Ownable** | Implementation | |||
 <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | transferOwnership | Public ❗ | 🛑 | onlyOwner |
| └ | owner | Internal 🔒 |  | |
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

```

🛑


🔒


❗


🛑


❗


❗


❗


❗


-----

```
| └ | totalSupply | External ❗ |  |NO❗ |
| └ | balanceOf | Public ❗ |  |NO❗ |
| └ | transfer | External ❗ | 🛑 |NO❗ |
| └ | allowance | External ❗ |  |NO❗ |
| └ | approve | External ❗ | 🛑 |NO❗ |
| └ | transferFrom | External ❗ | 🛑 |NO❗ |
| └ | increaseAllowance | Public ❗ | 🛑 |NO❗ |
| └ | decreaseAllowance | Public ❗ | 🛑 |NO❗ |
| └ | _transfer | Internal 🔒 | 🛑 | |
| └ | _approve | Internal 🔒 | 🛑 | |
||||||
| **SLEEPZ** | Implementation | BEP20 |||
| └ | <Constructor> | Public ❗ | 🛑 | BEP20 |
| └ | _transfer | Internal 🔒 | 🛑 | |
| └ | <Receive Ether> | External ❗ | 💵 |NO❗ |
| └ | _takeTax | Private 🔐 | 🛑 | |
| └ | _getTotalTax | Private 🔐 |  | |
| └ | _shouldSwapBack | Private 🔐 |  | |
| └ | _swapBack | Private 🔐 | 🛑 | swapping |
| └ | enableTrading | External ❗ | 🛑 | onlyOwner |
| └ | triggerSwapBack | External ❗ | 🛑 | onlyOwner |
| └ | burnFromStorage | External ❗ | 🛑 | onlyOwner |
| └ | recoverBNB | External ❗ | 🛑 | onlyOwner |
| └ | recoverBEP20 | External ❗ | 🛑 | onlyOwner |
| └ | setIsWhitelisted | External ❗ | 🛑 | onlyOwner |
| └ | setIsCEX | External ❗ | 🛑 | onlyOwner |
| └ | setIsMarketMaker | External ❗ | 🛑 | onlyOwner |
| └ | setTaxes | External ❗ | 🛑 | onlyOwner |
| └ | setShares | External ❗ | 🛑 | onlyOwner |
| └ | setSwapBackSettings | External ❗ | 🛑 | onlyOwner |
| └ | setTransferGas | External ❗ | 🛑 | onlyOwner |
| └ | setDevelopmentWallet | External ❗ | 🛑 | onlyOwner |
| └ | setMarketingWallet | External ❗ | 🛑 | onlyOwner |
| └ | setRewardWallet | External ❗ | 🛑 | onlyOwner |

```
```
| └ | decreaseAllowance | Public ❗ | 🛑 |NO❗ |
| └ | _transfer | Internal 🔒 | 🛑 | |
| └ | _approve | Internal 🔒 | 🛑 | |
**SLEEPZ** | Implementation | BEP20 |||
 <Constructor> | Public ❗ | 🛑 | BEP20 |
| └ | _transfer | Internal 🔒 | 🛑 | |
 <Receive Ether> | External ❗ | 💵 |NO❗ |
| └ | _takeTax | Private 🔐 | 🛑 | |
| └ | _getTotalTax | Private 🔐 |  | |
| └ | _shouldSwapBack | Private 🔐 |  | |
| └ | _swapBack | Private 🔐 | 🛑 | swapping |
| └ | enableTrading | External ❗ | 🛑 | onlyOwner |
| └ | triggerSwapBack | External ❗ | 🛑 | onlyOwner |
| └ | burnFromStorage | External ❗ | 🛑 | onlyOwner |
| └ | recoverBNB | External ❗ | 🛑 | onlyOwner |
| └ | recoverBEP20 | External ❗ | 🛑 | onlyOwner |
| └ | setIsWhitelisted | External ❗ | 🛑 | onlyOwner |
| └ | setIsCEX | External ❗ | 🛑 | onlyOwner |
| └ | setIsMarketMaker | External ❗ | 🛑 | onlyOwner |
| └ | setTaxes | External ❗ | 🛑 | onlyOwner |
| └ | setShares | External ❗ | 🛑 | onlyOwner |
| └ | setSwapBackSettings | External ❗ | 🛑 | onlyOwner |
| └ | setTransferGas | External ❗ | 🛑 | onlyOwner |
| └ | setDevelopmentWallet | External ❗ | 🛑 | onlyOwner |
| └ | setMarketingWallet | External ❗ | 🛑 | onlyOwner |
| └ | setRewardWallet | External ❗ | 🛑 | onlyOwner |

```

❗


❗


❗


❗


❗


🛑


❗


❗


🛑


-----

## Software Analysis

### Function Signatures
```
39509351 => increaseAllowance(address,uint256)
c9c65396 => createPair(address,address)
c45a0155 => factory()
ad5c4648 => WETH()
18cbafe5 => swapExactTokensForETH(uint256,uint256,address[],address,uint256)
f2fde38b => transferOwnership(address)
8da5cb5b => owner()
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
a457c2d7 => decreaseAllowance(address,uint256)
30e0789e => _transfer(address,address,uint256)
104e81ff => _approve(address,address,uint256)
56cdd3bc => _takeTax(address,address,uint256)
e27b0e71 => _getTotalTax(address,address)
c1196b7e => _shouldSwapBack(address)
cdd8861d => _swapBack()
8a8c523c => enableTrading()
456d401a => triggerSwapBack()
c3f06e55 => burnFromStorage(uint256)
6bfdf8a0 => recoverBNB()
6258eb92 => recoverBEP20(IBEP20,address)
09ec923a => setIsWhitelisted(address,bool)
ab261a40 => setIsCEX(address,bool)
974f7a51 => setIsMarketMaker(address,bool)
e9dae5ed => setTaxes(uint256,uint256,uint256)
a0885e93 => setShares(uint256,uint256,uint256)
df20fd49 => setSwapBackSettings(bool,uint256)
c7e066ba => setTransferGas(uint256)
72ac2486 => setDevelopmentWallet(address)
5d098b38 => setMarketingWallet(address)
5958621e => setRewardWallet(address)

```
```
c45a0155 => factory()
ad5c4648 => WETH()
18cbafe5 => swapExactTokensForETH(uint256,uint256,address[],address,uint256)
f2fde38b => transferOwnership(address)
8da5cb5b => owner()
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
a457c2d7 => decreaseAllowance(address,uint256)
30e0789e => _transfer(address,address,uint256)
104e81ff => _approve(address,address,uint256)
56cdd3bc => _takeTax(address,address,uint256)
e27b0e71 => _getTotalTax(address,address)
c1196b7e => _shouldSwapBack(address)
cdd8861d => _swapBack()
8a8c523c => enableTrading()
456d401a => triggerSwapBack()
c3f06e55 => burnFromStorage(uint256)
6bfdf8a0 => recoverBNB()
6258eb92 => recoverBEP20(IBEP20,address)
09ec923a => setIsWhitelisted(address,bool)
ab261a40 => setIsCEX(address,bool)
974f7a51 => setIsMarketMaker(address,bool)
e9dae5ed => setTaxes(uint256,uint256,uint256)
a0885e93 => setShares(uint256,uint256,uint256)
df20fd49 => setSwapBackSettings(bool,uint256)
c7e066ba => setTransferGas(uint256)
72ac2486 => setDevelopmentWallet(address)
5d098b38 => setMarketingWallet(address)
5958621e => setRewardWallet(address)

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

returns a set number of tokens from a spender to

**Allowance** Yes **Passed**

the owner

executes transfers of a specified number of

**Burn** Yes **! Low**

tokens to a burn address

executes fee collection from swap events and/or

**Contract Fees** Yes **! Low**

transfer events

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

returns a set number of tokens from a spender to

**Allowance** Yes **Passed**

the owner

executes transfers of a specified number of

Yes **! Low**

tokens to a burn address

executes fee collection from swap events and/or

**Contract Fees** Yes **! Low**

transfer events

executes transfer of contract ownership to a

**Transfer Ownership** Yes **Passed**

specified wallet

**Renounce** executes transfer of contract ownership to a

Yes **Passed**

**Ownership** dead address


-----

### 