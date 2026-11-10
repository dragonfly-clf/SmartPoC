#### L14 - Uninitialized Variables in Local Scope

|Criticality|Minor / Informative|
|---|---|
|Location|Nabana.sol#L2101,2141,2142,2143,2144,2157,2158,2159,2160,2174,2220,2221,22 22,2223,2333|
|Status|Unresolved|


##### Description


Using an uninitialized local variable can lead to unpredictable behavior and
potentially cause errors in the contract. It's important to always initialize local
variables with appropriate values before using them.


##### Recommendation


By initializing local variables before using them, the contract ensures that the
functions behave as expected and avoid potential issues.


-----

