#### L02 - State Variables could be Declared Constant

|Criticality|Minor / Informative|
|---|---|
|Location|BEP20LUNAINU.sol#L195|
|Status|Unresolved|


##### Description


State variables can be declared as constant using the constant keyword. This
means that the value of the state variable cannot be changed after it has been set.
Additionally, the constant variables decrease gas consumption of the corresponding
transaction.


##### Recommendation


Constant state variables can be useful when the contract wants to ensure that the
value of a state variable cannot be changed by any function in the contract. This
can be useful for storing values that are important to the contract's behavior, such
as the contract's address or the maximum number of times a certain function can
be called. The team is advised to add the constant keyword to state variables that
never change.


-----

