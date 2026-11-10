#### L04 - Conformance to Solidity Naming Conventions

**Criticality** Minor / Informative

**Location** FirmSeed.sol#L50,77,78,79,97

**Status** Unresolved

#### Description

The Solidity style guide is a set of guidelines for writing clean and consistent Solidity code.

Adhering to a style guide can help improve the readability and maintainability of the Solidity

code, making it easier for others to understand and work with.

The followings are a few key points from the Solidity style guide:

1. Use camelCase for function and variable names, with the first letter in lowercase

(e.g., myVariable, updateCounter).

2. Use PascalCase for contract, struct, and enum names, with the first letter in

uppercase (e.g., MyContract, UserStruct, ErrorEnum).

3. Use uppercase for constant variables and enums (e.g., MAX_VALUE,

ERROR_CODE).

4. Use indentation to improve readability and structure.

5. Use spaces between operators and after commas.

6. Use comments to explain the purpose and behavior of the code.

7. Keep lines short (around 120 characters) to improve readability.
```
 function WETH() external pure returns (address);
 string constant private _name = "FirmSeed"
 string constant private _symbol = "FIRM"
 uint8 constant private _decimals = 9
 uint256 constant private _totalSupply = 50 * 10**6 * 10**_decimals

#### Recommendation

```
By following the Solidity naming convention guidelines, the codebase increased the

readability, maintainability, and makes it easier to work with.


-----

Find more information on the Solidity documentation

[https://docs.soliditylang.org/en/v0.8.17/style-guide.html#naming-convention.](https://docs.soliditylang.org/en/v0.8.17/style-guide.html#naming-conventions)


-----

