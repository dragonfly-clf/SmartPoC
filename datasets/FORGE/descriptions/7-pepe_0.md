#### UEST - Unhandled Exception Stops Transfer


#### Description


The contract uses a try-catch statement in order to performe an external call to the router


contract. If the external call throw an exception, then the contract will return from the


function call. As a result, the transfer will stop the execution in the middle and the


`swapping` will stay locked for ever.


#### Recommendation


The team is advised to properly handle the external calls so they do not produce


unexpected side-effects to the contract.


-----

