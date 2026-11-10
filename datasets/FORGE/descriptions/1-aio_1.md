#### RZAC - Redundant Zero Address Check


#### Description


The contract contains a modifier called "onlyTokenBurner" that includes a redundant check


to verify if the sender is not the zero address. The check is unnecessary because it is


impossible for the caller to be the zero address.


#### Recommendation


The team is advised to remove the redundant check for the zero address in the


"onlyTokenBurner" modifier. By eliminating this unnecessary condition, the code becomes


more concise, increases gas efficiency and maintains a clear focus on the essential


authorization verification step.


-----

