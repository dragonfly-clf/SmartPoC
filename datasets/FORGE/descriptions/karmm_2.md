#### RVD - Redundant Variable Declaration

**Criticality** Minor / Informative

**Location** KARMMToken.sol#L645

**Status** Unresolved

#### Description

The contract contains the `DECIMALS` variable that is set to `18, which is a standard`

practice in ERC-20 token contracts to define the token's divisibility. However, this

`DECIMALS` variable is not actively used in the contract's calculations or functions. Instead,

the contract directly multiplies the `INITIAL_SUPPLY` value by `10**18, effectively`

hardcoding the decimal value. This approach bypasses the need for the `DECIMALS`

variable, rendering it redundant. The presence of an unused variable like `DECIMALS` not

only adds unnecessary complexity to the contract but also could lead to confusion about

the contract's design and its tokenomics.
```
   uint256 public constant INITIAL_SUPPLY = 3_000_000_000 *
 10**18; // Total supply of 3 billion tokens
   uint8 public constant DECIMALS = 18;

#### Recommendation

```
It is recommended to either remove the `DECIMALS` variable from the contract if it is not

being utilized in any computations or functions, or alternatively, to revise the contract to use

the `DECIMALS` variable for calculating the actual `INITIAL_SUPPLY` value. This will

enhance the clarity and efficiency of the contract's code. Additionally, it will prevent any

potential misunderstandings or errors that might arise from the presence of an unused

variable.


-----

