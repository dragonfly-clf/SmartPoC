#### FAI - Fees Application Inconsistency

**Criticality** Minor / Informative

**Location** SHYTCOIN.sol#L500

**Status** Unresolved

#### Description

The contract applies sell fees when the recipient is the pair address, buy fees when the

sender is the pair address, and zero fees in all the other cases. On the contrary, the contract

is taking fees if either the sender or recipient is excluded from fees. This methodology

creates an inconsistency since zero fees essentially mean that it should not apply fees.
```
 if(to == pair){
   taxes.rfi = selltaxes.rfi;
   taxes.marketing = selltaxes.marketing;
 }else if(from == pair){
   taxes.rfi = taxes.rfi;
   taxes.marketing = taxes.marketing;
 }else{
   taxes.rfi = 0;
   taxes.marketing = 10;
 }
 ...
 bool takeFee = true;
 if (swapping || _isExcludedFromFee[from] || _isExcludedFromFee[to])
 takeFee = false;

#### Recommendation

```
The team is advised to comprehensively review and adjust the fee calculation mechanism

within the contract. The contract should keep consistency between taking fees and

applying zero percentage fees.


-----

