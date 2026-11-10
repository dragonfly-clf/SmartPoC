#### RMO - Redundant Mint Override


#### Description


The `_mint()` method of the `ERC20` contract is private. As a result, it cannot be called


from an external user. Since the `NINJATURTLES` contract calls the `_mint()` once in the


initializer method, then the `_mint()` override is redundant.


#### Recommendation


The team is advised to remove the override of the `_mint()` method since it cannot be


called after the initialization.


-----

