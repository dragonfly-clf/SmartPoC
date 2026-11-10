#### L17 - Usage of Solidity Assembly

**Criticality** Minor / Informative

**Location** Guitarist.sol#L351,498,1495

**Status** Unresolved

#### Description

Using assembly can be useful for optimizing code, but it can also be error-prone. It's

important to carefully test and debug assembly code to ensure that it is correct and does

not contain any errors.

Some common types of errors that can occur when using assembly in Solidity include

Syntax, Type, Out-of-bounds, Stack, and Revert.
```
 assembly { size := extcodesize(account) }
 assembly {
   let returndata_size := mload(returndata)
   revert(add(32, returndata), returndata_size)
          }
 assembly {
    revert(add(32, reason), mload(reason))
    }

#### Recommendation

```
It is recommended to use assembly sparingly and only when necessary, as it can be difficult

to read and understand compared to Solidity code.


-----

