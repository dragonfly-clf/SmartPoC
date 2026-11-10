#### RSK - Redundant Storage Keyword

**Criticality** Minor / Informative

**Location** PymeToken.sol#L1545,2279,2289,2299,2309,2319,2329,2329,2339,2349,
2349,2381,2414,2414,2432,2432,2450,2450,4374,4542,4542,4714,4757

**Status** Unresolved

#### Description

The contract uses the `storage` keyword in a view function. The `storage` keyword is

used to persist data on the contract's storage. View functions are functions that do not

modify the state of the contract and do not perform any actions that cost gas (such as

sending a transaction). As a result, the use of the `storage` keyword in view functions is

redundant.
```
 Counter storage counter
 AddressSlot storage r
 BooleanSlot storage r
 Bytes32Slot storage r
 Uint256Slot storage r
 StringSlot storage r
 string storage store
 BytesSlot storage r
 bytes storage store
 uint256[] storage array
 address[] storage arr
 StorageSlotUpgradeable.AddressSlot storage
 bytes32[] storage arr
 StorageSlotUpgradeable.Bytes32Slot storage
 ...

#### Recommendation

```
It is generally considered good practice to avoid using the `storage` keyword in view

functions because it is unnecessary and can make the code less readable.


-----

