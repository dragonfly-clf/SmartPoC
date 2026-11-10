## QSP-8 Incorrect value for supported currencies

#### Severity: Medium Risk

 Status: Fixed

###### File(s) affected: RariFundManager.sol in rari-stable-pool-contracts and rari-yield-pool-contracts


###### Description: The array index of the left-hand side member of the assignment in the following code snippet located in RariFundManager.sol does not change for any loop iteration and it is out of bounds for the acceptedCurrencies array:

```
for (uint256 i = 0; i < _supportedCurrencies.length; i++) if (_acceptedCurrencies[_supportedCurrencies[i]]) acceptedCurrencies[acceptedCurrencies.length] = _supportedCurrencies[i];

```

###### Therefore this loop will not fill in all the supported currencies as the function is expected to do and the return values will be incorrect.


-----

###### Recommendation: Change the array index of the left-hand side member of the assignment to an index value that keeps increasing when a new value is added inside the if-statement.

