#### EIS - Excessively Integer Size

**Criticality** Minor / Informative

**Location** Token.sol#L220,223

**Status** Unresolved

#### Description

The contract is using a bigger unsigned integer data type that the maximum size that is

required. By using an unsigned integer data type larger than necessary, the smart contract

consumes more storage space and requires additional computational resources for

calculations and operations involving these variables. This can result in higher transaction

costs, longer execution times, and potential scalability bottlenecks.
```
 uint256 constant public fee_denominator = 1_000;
 uint256 constant public maxFee = 150;

#### Recommendation

```
To address the inefficiency associated with using an oversized unsigned integer data type, it

is recommended to accurately determine the required size based on the range of values the

variable needs to represent.


-----

