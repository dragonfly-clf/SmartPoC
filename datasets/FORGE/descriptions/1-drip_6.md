#### MVN - Misleading Variables Naming

**Criticality** Minor / Informative

**Location** DripToken.sol#L347

**Status** Unresolved

#### Description

Variables can have misleading names if their names do not accurately reflect the value they

contain or the purpose they serve. The contract uses some variable names that are too

generic or do not clearly convey the information stored in the variable. Misleading variable

names can lead to confusion, making the code more difficult to read and understand.

Specifically, the contract is utilizing the variables `swapAndLiquifyEnabled` and

`swapThreshold` in a conditional statement that triggers the `transferTaxes`

function. However, the actual implementation is different from what these variable names

suggest, as they are processed to a `transfer` functionality and not to a swap

functionality. This discrepancy between the variable names and their actual use can lead to

confusion and misunderstandings for developers, auditors, or anyone else reading the

code.
```
     if(!inSwapAndLiquify && from != uniswapV2Pair &&
 swapAndLiquifyEnabled && balanceOf(address(this)) >
 swapThreshold){
        transferTaxes();
      }

#### Recommendation

```
It's always a good practice for the contract to contain variable names that are specific and

descriptive. It is recommended to rename the variables `swapAndLiquifyEnabled` and

`swapThreshold` to names that accurately reflect their actual purpose and

implementation within the contract.


-----

