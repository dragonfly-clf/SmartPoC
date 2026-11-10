###### 1. Burn issue

**Issue:**

###### • At every transfer with burn wallet it’s balances changing, also total

supply is decreasing. After some number of that kind of operations
sum of the contract balances will not equal total supply.

**Recommendation:**

Revise burn logic of the contract and keep only one way of burning –
decreasing total supply, or sending tokens to zero address.

####  Medium Severity Issues

No medium severity issues found.

####  Low Severity Issues

No low severity issues found.