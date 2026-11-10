#### MTS - Manipulate Total Supply

**Criticality** minor

**Location** contract.sol#L701

##### Description

Owner is able to manipulate total supply. This change will have a direct impact on
the token price and Market Cap.

|Criticality|minor|
|---|---|
|Location|contract.sol#L701|


for (uint256 i = 0; i < times; i++) {

_totalSupply = _totalSupply

.mul((10**RATE_DECIMALS).add(rebaseRate))
.div(10**RATE_DECIMALS);
}


##### Recommendation

The contract owner should carefully manage the adjustment of the circulating
supply (increases or decreases), according to the token’s price fluctuations.


-----

