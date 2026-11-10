#### DKO - Delete Keyword Optimization

**Criticality** Minor / Informative

**Location** ZangAi.sol#L645

**Status** Unresolved

#### Description

The contract resets variables to the default state by setting the initial values. Setting values

to state variables increases the gas cost.
```
 function removeAllFee() private {
   if(_taxFee == 0 && _liquidityFee == 0 && _marketingFee ==
 0) return;
   _taxFee = 0;
   _marketingFee = 0;
   _liquidityFee = 0;
 }

#### Recommendation

```
The team is advised to use the `delete` keyword instead of setting variables. This can be

more efficient than setting the variable to a new value, using delete can reduce the gas cost

associated with storing data on the blockchain.


-----

