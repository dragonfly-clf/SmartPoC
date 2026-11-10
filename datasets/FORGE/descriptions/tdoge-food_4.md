#### RLC - Redundant Limit Checks

**Criticality** minor / informative

**Location** contract.sol#L352,355,370

**Status** Unresolved

##### Description

The contract is using redundant checks. The variables maxSellAmount,
maxBuyAmount, and walletLimit are all equal to the totalSupply, so they can never
be reached.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L352,355,370|
|Status|Unresolved|


require(tAmount <= maxSellAmount,"over max sell amount");
…
require(tAmount <= maxBuyAmount,"over max buy amount");
…
require((balanceOf(recipient) + tAmount - feeAmount) <= walletLimit,"over max wallet limit");


##### Recommendation

The team is advised to remove these checks and therefore the variable declarations,
as they are not required.


-----

