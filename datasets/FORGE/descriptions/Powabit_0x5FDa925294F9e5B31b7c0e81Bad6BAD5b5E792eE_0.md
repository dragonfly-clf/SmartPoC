Powabit’s Centralization Status

v Powabit’s smart contract has an active ownership.


-----

## Static Analysis

**Symbol** **Meaning**

🛑 Function can modify state

💵 Function is payable

🔒 Function is locked

🔐 Function can be accessed

❗ Important functionality
```
| **Context** | Implementation | |||
| └ | _msgSender | Internal 🔒 |  | |
| └ | _msgData | Internal 🔒 |  | |
||||||
| **SafeMath** | Library | |||
| └ | add | Internal 🔒 |  | |
| └ | sub | Internal 🔒 |  | |
| └ | sub | Internal 🔒 |  | |
| └ | mul | Internal 🔒 |  | |
| └ | div | Internal 🔒 |  | |
| └ | div | Internal 🔒 |  | |
| └ | mod | Internal 🔒 |  | |
| └ | mod | Internal 🔒 |  | |

```

🛑


🔒


❗

```
||||||

```

💵

```
| **Address** | Library | |||
| └ | isContract | Internal 🔒 |  | |
| └ | sendValue | Internal 🔒 | 🛑 | |
| └ | functionCall | Internal 🔒 | 🛑 | |
| └ | functionCall | Internal 🔒 | 🛑 | |
| └ | functionCallWithValue | Internal 🔒 | 🛑 | |
| └ | functionCallWithValue | Internal 🔒 | 🛑 | |
| └ | _functionCallWithValue | Private 🔐 | 🛑 | |
||||||
| **IBEP20** | Interface | |||
| └ | totalSupply | External ❗ |  |NO❗ |
| └ | decimals | External ❗ |  |NO❗ |
| └ | symbol | External ❗ |  |NO❗ |
| └ | name | External ❗ |  |NO❗ |
| └ | getOwner | External ❗ |  |NO❗ |
| └ | balanceOf | External ❗ |  |NO❗ |
| └ | transfer | External ❗ | 🛑 |NO❗ |

```

Function is payable

Function is locked

Function can be accessed

Important functionality
```
**Context** | Implementation | |||
| └ | _msgSender | Internal 🔒 |  | |
| └ | _msgData | Internal 🔒 |  | |
**SafeMath** | Library | |||
| └ | add | Internal 🔒 |  | |
| └ | sub | Internal 🔒 |  | |
| └ | sub | Internal 🔒 |  | |
| └ | mul | Internal 🔒 |  | |
| └ | div | Internal 🔒 |  | |
| └ | div | Internal 🔒 |  | |
| └ | mod | Internal 🔒 |  | |
| └ | mod | Internal 🔒 |  | |
**Address** | Library | |||
| └ | isContract | Internal 🔒 |  | |
| └ | sendValue | Internal 🔒 | 🛑 | |
| └ | functionCall | Internal 🔒 | 🛑 | |
| └ | functionCall | Internal 🔒 | 🛑 | |
| └ | functionCallWithValue | Internal 🔒 | 🛑 | |
| └ | functionCallWithValue | Internal 🔒 | 🛑 | |
| └ | _functionCallWithValue | Private 🔐 | 🛑 | |
**IBEP20** | Interface | |||
| └ | totalSupply | External ❗ |  |NO❗ |

```

🔐


❗


❗


❗


❗


❗


🛑


-----

```
| └ | allowance | External ❗ |  |NO❗ |
| └ | approve | External ❗ | 🛑 |NO❗ |
| └ | transferFrom | External ❗ | 🛑 |NO❗ |
||||||
| **Ownable** | Implementation | Context |||
| └ | <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | owner | Public ❗ |  |NO❗ |
| └ | renounceOwnership | Public ❗ | 🛑 | onlyOwner |
| └ | transferOwnership | Public ❗ | 🛑 | onlyOwner |
| └ | _transferOwnership | Internal 🔒 | 🛑 | |
||||||
| **PowabitToken** | Implementation | Context, IBEP20, Ownable |||
| └ | <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | getOwner | External ❗ |  |NO❗ |
| └ | decimals | External ❗ |  |NO❗ |
| └ | symbol | External ❗ |  |NO❗ |
| └ | name | External ❗ |  |NO❗ |
| └ | totalSupply | External ❗ |  |NO❗ |
| └ | balanceOf | External ❗ |  |NO❗ |
| └ | transfer | External ❗ | 🛑 |NO❗ |
| └ | allowance | External ❗ |  |NO❗ |
| └ | approve | External ❗ | 🛑 |NO❗ |
| └ | transferFrom | External ❗ | 🛑 |NO❗ |
| └ | increaseAllowance | Public ❗ | 🛑 |NO❗ |
| └ | decreaseAllowance | Public ❗ | 🛑 |NO❗ |
| └ | mint | Public ❗ | 🛑 | onlyOwner |
| └ | burn | Public ❗ | 🛑 |NO❗ |
| └ | _transfer | Internal 🔒 | 🛑 | |
| └ | _mint | Internal 🔒 | 🛑 | |
| └ | _burn | Internal 🔒 | 🛑 | |
| └ | _approve | Internal 🔒 | 🛑 | |
| └ | _burnFrom | Internal 🔒 | 🛑 | |

```
```
| └ | renounceOwnership | Public ❗ | 🛑 | onlyOwner |
| └ | transferOwnership | Public ❗ | 🛑 | onlyOwner |
| └ | _transferOwnership | Internal 🔒 | 🛑 | |
**PowabitToken** | Implementation | Context, IBEP20, Ownable |||
 <Constructor> | Public ❗ | 🛑 |NO❗ |
| └ | getOwner | External ❗ |  |NO❗ |
| └ | decimals | External ❗ |  |NO❗ |
| └ | symbol | External ❗ |  |NO❗ |
| └ | name | External ❗ |  |NO❗ |
| └ | totalSupply | External ❗ |  |NO❗ |
| └ | balanceOf | External ❗ |  |NO❗ |
| └ | transfer | External ❗ | 🛑 |NO❗ |
| └ | allowance | External ❗ |  |NO❗ |
| └ | approve | External ❗ | 🛑 |NO❗ |
| └ | transferFrom | External ❗ | 🛑 |NO❗ |
| └ | increaseAllowance | Public ❗ | 🛑 |NO❗ |
| └ | decreaseAllowance | Public ❗ | 🛑 |NO❗ |
| └ | mint | Public ❗ | 🛑 | onlyOwner |
| └ | burn | Public ❗ | 🛑 |NO❗ |
| └ | _transfer | Internal 🔒 | 🛑 | |
| └ | _mint | Internal 🔒 | 🛑 | |
| └ | _burn | Internal 🔒 | 🛑 | |
| └ | _approve | Internal 🔒 | 🛑 | |
| └ | _burnFrom | Internal 🔒 | 🛑 | |

```

❗


❗


❗


🛑


❗


❗


❗


-----

## Software Analysis

### Function Signatures
```
16279055 => isContract(address)
39509351 => increaseAllowance(address,uint256)
119df25f => _msgSender()
8b49d47e => _msgData()
771602f7 => add(uint256,uint256)
b67d77c5 => sub(uint256,uint256)
e31bdc0a => sub(uint256,uint256,string)
c8a4ac9c => mul(uint256,uint256)
a391c15b => div(uint256,uint256)
b745d336 => div(uint256,uint256,string)
f43f523a => mod(uint256,uint256)
71af23e8 => mod(uint256,uint256,string)
24a084df => sendValue(address,uint256)
a0b5ffb0 => functionCall(address,bytes)
241b5886 => functionCall(address,bytes,string)
2a011594 => functionCallWithValue(address,bytes,uint256)
d525ab8a => functionCallWithValue(address,bytes,uint256,string)
36455e42 => _functionCallWithValue(address,bytes,uint256,string)
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
8da5cb5b => owner()
715018a6 => renounceOwnership()
f2fde38b => transferOwnership(address)
d29d44ee => _transferOwnership(address)
a457c2d7 => decreaseAllowance(address,uint256)
a0712d68 => mint(uint256)
42966c68 => burn(uint256)
30e0789e => _transfer(address,address,uint256)
4e6ec247 => _mint(address,uint256)
6161eb18 => _burn(address,uint256)
104e81ff => _approve(address,address,uint256)
a22b35ce => _burnFrom(address,uint256)

```
```
119df25f => _msgSender()
8b49d47e => _msgData()
771602f7 => add(uint256,uint256)
b67d77c5 => sub(uint256,uint256)
e31bdc0a => sub(uint256,uint256,string)
c8a4ac9c => mul(uint256,uint256)
a391c15b => div(uint256,uint256)
b745d336 => div(uint256,uint256,string)
f43f523a => mod(uint256,uint256)
71af23e8 => mod(uint256,uint256,string)
24a084df => sendValue(address,uint256)
a0b5ffb0 => functionCall(address,bytes)
241b5886 => functionCall(address,bytes,string)
2a011594 => functionCallWithValue(address,bytes,uint256)
d525ab8a => functionCallWithValue(address,bytes,uint256,string)
36455e42 => _functionCallWithValue(address,bytes,uint256,string)
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
8da5cb5b => owner()
715018a6 => renounceOwnership()
f2fde38b => transferOwnership(address)
d29d44ee => _transferOwnership(address)
a457c2d7 => decreaseAllowance(address,uint256)
a0712d68 => mint(uint256)
42966c68 => burn(uint256)
30e0789e => _transfer(address,address,uint256)
4e6ec247 => _mint(address,uint256)
6161eb18 => _burn(address,uint256)
104e81ff => _approve(address,address,uint256)

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

**Burn** Yes **Passed**

tokens to a burn address

executes the creation of a specified number of

**Mint** Yes **! High**

tokens and adds it to the total supply

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

Yes **Passed**

tokens to a burn address

executes the creation of a specified number of

Yes **! High**

tokens and adds it to the total supply

executes transfer of contract ownership to a

**Transfer Ownership** Yes **Passed**

specified wallet

**Renounce** executes transfer of contract ownership to a

Yes **Passed**

**Ownership** dead address


-----

### Notable Information 📝

v Smart contract owner can mint tokens after initial contract creation/deployment.
```
  function mint(uint256 amount) public onlyOwner returns (bool) {
  _mint(_msgSender(), amount);

```
v Smart contract utilizes safemath function to avoid common smart contract vulnerabilities.


### 📝

```
  string private _name = "Powabit";

```
```
  library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
     require(c >= a, "SafeMath: addition overflow");
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
     return sub(a, b, "SafeMath: subtraction overflow");
    uint256 c = a * b;
     require(c / a == b, "SafeMath: multiplication overflow");
     return c;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     return div(a, b, "SafeMath: division by zero");
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
     return mod(a, b, "SafeMath: modulo by zero");

```
v Smart contract utilizes redundant code for `transferOwnership(). Ideal transfer ownership`

code should look be written like:
```
  function transferOwnership(address newOwner) public virtual onlyOwner {
     require(newOwner != address(0), "Ownable: new owner is the zero address");
     emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;

```
v Smart contract has a **low severity issue which may or may not create any functional**

vulnerability.

**"severity": 8, (! Low Severity)**

**“Expected pragma, import directive or contract/interface/library definition”**

```
_mint(_msgSender(), amount);

```
v Smart contract utilizes safemath function to avoid common smart contract vulnerabilities.
```
  string private _name = "Powabit";
library SafeMath {
function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
  require(c >= a, "SafeMath: addition overflow");
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
  return sub(a, b, "SafeMath: subtraction overflow");
    uint256 c = a * b;
  require(c / a == b, "SafeMath: multiplication overflow");
  return c;
function div(uint256 a, uint256 b) internal pure returns (uint256) {
  return div(a, b, "SafeMath: division by zero");
function mod(uint256 a, uint256 b) internal pure returns (uint256) {
  return mod(a, b, "SafeMath: modulo by zero");

```
v Smart contract utilizes redundant code for `transferOwnership(). Ideal transfer ownership`

code should look be written like:
```
function transferOwnership(address newOwner) public virtual onlyOwner {
  require(newOwner != address(0), "Ownable: new owner is the zero address");
  emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;

```
v Smart contract has a **low severity issue which may or may not create any functional**

vulnerability.


-----

## 