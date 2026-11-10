#### MAL - Misused Algorithmic Logic

**Criticality** minor

**Location** contract.sol#L929

##### Description

The algorithmic flow does not follow the required business logic.

The calculation of tTranferAmount will provoke underflow if both fees are set to
100% due to the subtractions.

|Criticality|minor|
|---|---|
|Location|contract.sol#L929|


function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {

uint256 tFee = calculateTaxFee(tAmount);
uint256 tLiquidity = calculateLiquidityFee(tAmount);
uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
return (tTransferAmount, tFee, tLiquidity);
}


##### Recommendation

The algorithm should be reshaped so it will match to the business logic.


-----

