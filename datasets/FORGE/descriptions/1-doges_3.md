#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L159,165,495,499,503,507,515,520,524,529 and 12 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L159,165,495,499,503,507,515,520,524,529 and 12 more|

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

Use the external attribute for functions never called from the contract


-----

