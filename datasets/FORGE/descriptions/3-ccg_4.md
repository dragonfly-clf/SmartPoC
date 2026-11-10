#### L09 - Dead Code Elimination

**Criticality** Minor / Informative

**Location** LiquidityGeneratorToken.sol#L441,469,494,504,523,537,556,566,583,593
,610

**Status** Unresolved

#### Description

In Solidity, dead code is code that is written in the contract, but is never executed or

reached during normal contract execution. Dead code can occur for a variety of reasons,

such as:

  - Conditional statements that are always false.

  - Functions that are never called.

  - Unreachable code (e.g., code that follows a return statement).

Dead code can make a contract more difficult to understand and maintain, and can also

increase the size of the contract and the cost of deploying and interacting with it.
```
 function isContract(address account) internal view returns
 (bool) {
      // This method relies on extcodesize, which returns 0
 for contracts in
      // construction, since the code is only stored at the
 end of the
      // constructor execution.
      uint256 size;
      assembly {
        size := extcodesize(account)
      }
      return size > 0;
   }
 ...

#### Recommendation

```

-----

To avoid creating dead code, it's important to carefully consider the logic and flow of the

contract and to remove any code that is not needed or that is never executed. This can help

improve the clarity and efficiency of the contract.


-----

