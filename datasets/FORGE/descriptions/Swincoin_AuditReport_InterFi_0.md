Smart Contract – Manual Analysis

**Function** **Description** **Tested** **Verdict**

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

is an action in which the project buys back its

**Buy Back** tokens from the existing holders usually at a NA NA

market price

executes transfers of a specified number of

**Burn** NA NA

tokens to a burn address

executes creation of a specified number of

**Mint** Yes **! High**

tokens and adds it to the total supply

circulating token supply adjusts (increases or

**Rebase** decreases) automatically according to a token's NA NA

price fluctuations

stops specified wallets from interacting with the

**Blacklist** NA NA

smart contract function modules

stops or locks all function modules of the smart

**Lock** NA NA

contract


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

is an action in which the project buys back its

**Buy Back** tokens from the existing holders usually at a NA NA

market price

executes transfers of a specified number of

NA NA

tokens to a burn address

executes creation of a specified number of

Yes **! High**

tokens and adds it to the total supply

circulating token supply adjusts (increases or

**Rebase** decreases) automatically according to a token's NA NA

price fluctuations

stops specified wallets from interacting with the


-----

**Function** **Description** **Tested** **Verdict**

executes transfers of a specified dividend token

**Dividend** NA NA

to a specified address

executes transfers of a specified number of

**Airdrop** NA NA

tokens to a specified address

a non-whitelisted wallet can only transfer a

**Max Transaction** NA NA

specified number of tokens

a non-whitelisted wallet can only hold a

**Max Wallet** NA NA

specified number of tokens

functionality to limit the number of transactions

**Cooldown Timer** NA NA

that a wallet can make within a 24-hour span

stops some or all bot wallets from interacting

**Anti Bot** NA NA

with the smart contract

executes transfer of contract ownership to a

**Transfer Ownership** Yes **Passed**

specified wallet

**Renounce** executes transfer of contract ownership to a

Yes **Passed**

**Ownership** dead address


executes transfers of a specified number of

**Airdrop** NA NA

tokens to a specified address

a non-whitelisted wallet can only transfer a

**Max Transaction** NA NA

specified number of tokens

a non-whitelisted wallet can only hold a

**Max Wallet** NA NA

specified number of tokens

functionality to limit the number of transactions

**Cooldown Timer** NA NA

that a wallet can make within a 24-hour span

stops some or all bot wallets from interacting

**Anti Bot** NA NA

with the smart contract

executes transfer of contract ownership to a

**Transfer Ownership** Yes **Passed**

specified wallet

**Renounce** executes transfer of contract ownership to a

Yes **Passed**

**Ownership** dead address


-----

### Best Practices ✅

v Owner cannot stop or pause the smart contract.

v Owner cannot lock or burn the user assets.

### Warning 🛑

v Active smart contract owner: 0xA36Cad8953cE5f805B5f24C87086038c8bc1dbDd

v Be aware that active smart contract owner privileges constitute an elevated impact to smart

contract’s safety and security.

v Smart contract can mint tokens.


### Warning 🛑

v Active smart contract owner: 0xA36Cad8953cE5f805B5f24C87086038c8bc1dbDd

v Be aware that active smart contract owner privileges constitute an elevated impact to smart

contract’s safety and security.

v Smart contract can mint tokens.


### ✅


-----

## 