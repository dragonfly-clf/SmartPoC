#### L04 - Conformance to Solidity Naming Conventions

**Criticality** Minor / Informative

**Location** JLT.sol#L488,489,505,526,687,693,697,901,907,1132

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
 function DOMAIN_SEPARATOR() external view returns (bytes32);
 function PERMIT_TYPEHASH() external pure returns (bytes32);
 function MINIMUM_LIQUIDITY() external pure returns (uint);
 function WETH() external pure returns (address);
 uint256 public _taxFee = 1
 uint256 public _burnFee = 1
 uint256 public _treasuryFee = 1
 uint256 _amount
 bool _enabled

#### Recommendation

```

-----

By following the Solidity naming convention guidelines, the codebase increased the

readability, maintainability, and makes it easier to work with.

Find more information on the Solidity documentation

[https://docs.soliditylang.org/en/v0.8.17/style-guide.html#naming-convention.](https://docs.soliditylang.org/en/v0.8.17/style-guide.html#naming-conventions)


-----

