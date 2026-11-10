#### EIS - Excessively Integer Size

**Criticality** Minor / Informative

**Location** MitaoCat.sol#L302

**Status** Unresolved

#### Description

The contract is using a bigger unsigned integer data type that the maximum size that is

required. By using an unsigned integer data type larger than necessary, the smart contract

consumes more storage space and requires additional computational resources for

calculations and operations involving these variables. This can result in higher transaction

costs, longer execution times, and potential scalability bottlenecks.

Since the `currentTID` cannot be greater than 3 and the max fee value is 25.
```
 uint256 operationsFee;
 uint256 public buyTotalFees;
 uint256 public sellTotalFees;
 uint256 public currentTID = 0;
 function switchTaxStructure(uint256 tID) external onlyOwner {
   require(currentTID < tID && currentTID != 3, "You can only go
 up to TID 3.");
   buyFees memory buyFee = _buyFees[tID];
   sellFees memory sellFee = _sellFees[tID];
   buyTotalFees = buyFee.operationsFee;
   sellTotalFees = sellFee.operationsFee;
   currentTID = tID;
 }

#### Recommendation

```
To address the inefficiency associated with using an oversized unsigned integer data type, it

is recommended to accurately determine the required size based on the range of values the

variable needs to represent.


-----

We can safely assume that all the abovementioned variables could be defined as `uint8 .`


-----

