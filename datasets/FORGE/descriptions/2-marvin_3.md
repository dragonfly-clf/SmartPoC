#### CR - Code Repetition

**Criticality** Minor / Informative

**Location** MarvinInu.sol#L1198

**Status** Unresolved

#### Description

The contract contains repetitive code segments. There are potential issues that can arise

when using code segments in Solidity. Some of them can lead to issues like gas efficiency,

complexity, readability, security, and maintainability of the source code. It is generally a

good idea to try to minimize code repetition where possible.


-----

#### Recommendation

The team is advised to avoid repeating the same code in multiple places, which can make

the contract easier to read and maintain. The authors could try to reuse code wherever

possible, as this can help reduce the complexity and size of the contract. For instance, the


-----

contract could reuse the common code segments in an internal function in order to avoid

repeating the same code in multiple places.


-----

