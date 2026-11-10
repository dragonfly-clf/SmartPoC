#### L09 - Dead Code Elimination

**Criticality** minor

**Location** contract.sol#L1200,581,591,610,624,670,680,643,653,556,697,1639,1739,1747,1
331,1410,1438,1489,1522,1535,941,916,1687,1667,1695,1671,1679

##### Description

Functions that are not used in the contract, and make the code's size bigger.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1200,581,591,610,624,670,680,643,653,556,697,1639,1739,1747,1 331,1410,1438,1489,1522,1535,941,916,1687,1667,1695,1671,1679|

```
uint256ToString
uint160ToAddress
bytesToString
addressToUint160
addressToString
toString
toHexString
toTypedDataHash
toEthSignedMessageHash

```
...


##### Recommendation

Remove unused functions.


-----

