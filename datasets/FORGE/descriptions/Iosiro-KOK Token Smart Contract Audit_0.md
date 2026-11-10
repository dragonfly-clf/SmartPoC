#### 5.4.1 Design Comments

Actions to improve the functionality and readability of the codebase are outlined

below.

##### Use bool for Blacklist State

An `int type was use for storing whether an address was blacklisted. A more intuitive`

type for this binary state would be a boolean, using `true or` `false to indicate`

whether an address was blacklisted.

##### Use require for Blacklist

The `transfer(...) and` `transferFrom(...) functions returned` `false if attempting to`

transfer from or to a blacklisted address. While this is within the ERC-20 standard, a

more intuitive implementation would revert through a `require statement. This`

would prevent third-parties from potentially assuming that a transfer succeeded if

the return value of the function was not validated.

##### Use require for onlyOwner

The `onlyOwner modifier returned` `false instead of reverting. It is recommended that`

a `require statement be used to explicitly revert if the function is called by a non-`

dd


-----

In the ERC-20 standard it specifies that a Transfer event be emitted whenever there is

movement of tokens. On contract.sol#L63, the total supply is allocated to the
```
msg.sender, however no event is emitted. It is recommended that an event

```
transferring the tokens from 0x0 to the address be added.

##### Interface Incorrectly Defined

On contact.sol#L25 `ERC20Interface implies that the code should be an interface,`

however the `contract keyword was used. It is recommended that contact.sol#L26 be`

removed and the keyword changed to `interface .`

##### No Function Visibility

The `stop(...) and` `start(...) functions had an implied public visibility. It is`

recommended that a visibility is explicitly set on these functions by using the `public`

keyword to improve the readability of the code.

##### Inexact Compiler Version

The pragma version was not fixed to a specific version, as it specified `^0.4.21, which`

would result in using the highest non-breaking version (highest version below `0.5.0 ).`

According to best practice, where possible, all contracts should use the same

compiler version, which should be fixed to a specific version. This helps to ensure that

contracts do not accidentally get deployed using an alternative compiler, which may

pose the risk of unidentified bugs. An explicit version also helps with code reuse, as

users would be able to see the author’s intended compiler version. It is recommended

that the pragma version is changed to a fixed value, for example `0.4.25 .`

### 5.5 Closed

