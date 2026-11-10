#### L09 - Dead Code Elimination

**Criticality** Minor / Informative

**Location** JLT.sol#L335,362,388,398,413,423,428,794,798,1002

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
      // According to EIP-1052, 0x0 is the value returned for
 not-yet created accounts
      // and
 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a
 470 is returned
      // for accounts without code, i.e. `keccak256('')`
      bytes32 codehash;
      bytes32 accountHash =
 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a
 470;
      // solhint-disable-next-line no-inline-assembly
      assembly { codehash := extcodehash(account) }
      return (codehash != accountHash && codehash != 0x0);
   }
 ...

#### Recommendation

```

-----

To avoid creating dead code, it's important to carefully consider the logic and flow of the

contract and to remove any code that is not needed or that is never executed. This can help

improve the clarity and efficiency of the contract.


-----

