#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L160,166,496,500,504,508,516,521,525,530,536,541,563,568,594,
607,613,680,882,931,938,944

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L160,166,496,500,504,508,516,521,525,530,536,541,563,568,594, 607,613,680,882,931,938,944|

```
set_New_Pair_Address
set_New_Router_Address
set_New_Router_and_Make_Pair
process_Tokens_Now
blacklist_Switch
set_Number_Of_Transactions_Before_Liquify_Trigger
set_Swap_And_Liquify_Enabled
Wallet_Update_Dev
includeInFee

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

