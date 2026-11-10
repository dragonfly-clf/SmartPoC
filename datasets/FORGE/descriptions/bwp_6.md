#### PER - Presale Execution Requirement

**Criticality** minor / informative

**Location** contract.sol#L1531

**Status** Unresolved

##### Description

The contract initialises the presaleNFTPrice with zero. As a result, if the presale
begins with zero presaleNFTPrice, the investors will not be able to claim their
tokens.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1531|
|Status|Unresolved|

```
require(presaleNFTPrice > 0);

```

##### Recommendation

The contract should not depend on the presaleNFTPrice in order to proceed with
the presale functionality..


-----

