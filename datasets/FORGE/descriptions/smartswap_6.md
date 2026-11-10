#### RSV - Redundant Struct Variable

**Criticality** Minor / Informative

**Location** DP2PCoin.sol#L563
DP2PToken.sol#L328
DP2PTokenLegacyUSDT.sol#L328

**Status** Unresolved

#### Description

The contract is utilazin the `DealData` struct that encapsulates transaction-related

information, including addresses for token, seller, buyer, arbiter, and feeReceiver, alongside

values for amount, fee, and a nonce to ensure unique transaction hashes. The struct also

declares the `bytes32` variable `extra . However,` `the` extra variable is not utilized

in any of the contract's functions or state changes. As a result it does not contribute to the

contract's logic or provide additional functionality. The presence of this non-functional

variable leads to increased gas costs for operations involving the struct, as it occupies

storage space without serving a purpose.
```
   struct DealData {
      address token;
      address seller;
      address buyer;
      address arbiter;
      address feeReceiver;
      uint256 amount;
      uint256 fee;
      uint256 nonce;
      bytes32 extra;
   }

#### Recommendation

```
It is recommended to remove the `bytes32` `extra` variable from the `DealData`

struct since it does not alter the contract logic or add any meaningful functionality.

Eliminating this variable will result in gas optimization, reducing the cost associated with

deploying and interacting with the contract. Furthermore, the removal of unnecessary


-----

variables can simplify the contract's structure, making it more readable and easier to

maintain.


-----

