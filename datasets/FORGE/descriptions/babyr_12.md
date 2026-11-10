#### L12 - Using Variables before Declaration

|Criticality|Minor / Informative|
|---|---|
|Location|fal tten/BabyShibarium.sol#L1940,1941,1942|
|Status|Unresolved|


##### Description


The contract is using a variable before the declaration. This is usually happening
either if it has not been declared yet or if the variable has been declared in a
different scope. It is not a good practice to use a local variable before it has been
declared.


##### Recommendation


By declaring local variables before using them, contract ensures that it operates
correctly. It's important to be aware of this rule when working with local variables,
as using a variable before it has been declared can lead to unexpected behavior
and can be difficult to debug.


-----

