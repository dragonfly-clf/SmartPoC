#### L15 - Local Scope Variable Shadowing

**Criticality** Minor / Informative

**Location** JETFINDER.sol#L916,920

**Status** Unresolved

#### Description

Local scope variable shadowing occurs when a local variable with the same name as a

variable in an outer scope is declared within a function or code block. When this happens,

the local variable "shadows" the outer variable, meaning that it takes precedence over the

outer variable within the scope in which it is declared.
```
 address _owner = 0x98E91709B99ba1c09ebE9fA8caf93Cf025C5E686
 uint256 totalSupply = 1000000000 * (10**_decimals)

#### Recommendation

```
It's important to be aware of shadowing when working with local variables, as it can lead to

confusion and unintended consequences if not used correctly. It's generally a good idea to

choose unique names for local variables to avoid shadowing outer variables and causing

confusion.


-----

