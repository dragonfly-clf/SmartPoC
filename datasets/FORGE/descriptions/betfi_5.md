#### CR - Code Repetition

**Criticality** minor

**Location** contract.sol#L903,917

##### Description

There are code segments that are repetitive in the contract. Those segments
increase the code size of the contract unnecessarily.

The method handleTax can be optimized. The following code segment is repetitive.

|Criticality|minor|
|---|---|
|Location|contract.sol#L903,917|


tax += baseUnit * buyTaxes["marketing"];
tax += baseUnit * buyTaxes["dev"];
tax += baseUnit * buyTaxes["liquidity"];
tax += baseUnit * buyTaxes["charity"];

if(tax > 0) {

_transfer(from, address(this), tax);
}

marketingTokens += baseUnit * buyTaxes["marketing"];
devTokens += baseUnit * buyTaxes["dev"];
liquidityTokens += baseUnit * buyTaxes["liquidity"];
charityTokens += baseUnit * buyTaxes["charity"];


##### Recommendation

Create an internal function that contains the code segment and remove it from all
the sections.


-----

