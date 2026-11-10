#### CO - Code Optimization

**Criticality** minor / informative

**Location** contract.sol#L913,111

**Status** Unresolved

##### Description

There are code segments that could be optimized. A segment may be optimized so
that it becomes a smaller size, consumes less memory, executes more rapidly, or
performs fewer operations.

The method ‘_getSumOfFees’ is getting called even if the takeFee is not enabled.
This produces an unnecessary function call.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L913,111|
|Status|Unresolved|


uint256 sumOfFees = _getSumOfFees(sender, amount);
if (!takeFee) {

sumOfFees = 0;
}


The method ‘_getSumOfFees’ accepts two arguments that are not used.


function _getSumOfFees(address sender, uint256 amount)

internal
view
override
returns (uint256)
{

return sumOfFees;
}


##### Recommendation

The method ‘_getSumOfFees’ should be called only when the takeFee is enabled.
The two parameters could be eliminated since they are not used by the method.


-----

