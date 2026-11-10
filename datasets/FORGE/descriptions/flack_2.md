#### CRO - Code Readability Optimization

**Criticality** Minor / Informative

**Location** Flack.sol#L347

**Status** Unresolved

#### Description

The `checkSwapFee` function, designed to determine whether fees should be applied to

a transaction, currently features a more complex implementation than necessary. The

function checks various conditions and returns true only if either the sender or the recipient

is in the `_chargePair` mapping. In all other cases, it returns false. The logic can be

simplified by directly returning `_chargePair[sender] ||`
```
_chargePair[recipient] .
 function checkSwapFee(address sender, address recipient) internal view
 returns (bool) {
   if(_chargePair[sender] || _chargePair[recipient]) {
     return true;
   }
   else if (isMarketPair[sender] || isMarketPair[recipient]) {
     return false;
   }
   else {
     return false;
   }
 }

#### Recommendation

```
The is advised to simplify the logic in the `checkSwapFee` function by directly returning
```
_chargePair[sender] || _chargePair[recipient] . This streamlines the code,

```
making it more concise and easier to understand. The simplified version maintains the

intended behavior of the function while reducing unnecessary complexity.


-----

