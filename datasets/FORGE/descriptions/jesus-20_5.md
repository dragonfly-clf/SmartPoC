#### L03 - Redundant Statements

**Criticality** Minor / Informative

**Location** Jesus.sol#L401,406

**Status** Unresolved

#### Description

Redundant statements are statements that are unnecessary or have no effect on the

contract's behavior. These can include declarations of variables or functions that are not

used, or assignments to variables that are never used.

As a result, it can make the contract's code harder to read and maintain, and can also

increase the contract's size and gas consumption, potentially making it more expensive to

deploy and execute.
```
 buyLiquidityFee;
 sellLiquidityFee;

#### Recommendation

```
To avoid redundant statements, it's important to carefully review the contract's code and

remove any statements that are unnecessary or not used. This can help to improve the

clarity and efficiency of the contract's code.

By removing unnecessary or redundant statements from the contract's code, the clarity and

efficiency of the contract will be improved. Additionally, the size and gas consumption will

be reduced.


-----

