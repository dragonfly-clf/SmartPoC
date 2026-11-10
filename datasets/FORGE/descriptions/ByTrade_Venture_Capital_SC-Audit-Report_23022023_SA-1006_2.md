M01. Unscalable Functionality: Repeated Checks in Functions
   In ByTradeToken, the functions transfer(), transferFrom(), approve(),
   increaseAllowance() and decreaseAllowance() implement a require() to
   make sure none of the addresses involved in the transaction are
   blacklisted.
   This check is done calling isBlacklisted() twice at each of the
   mentioned functions, resulting in a repetitive code. Instead, a new
                www.hacken.io

```

-----

```
  modifier can be created, which includes these checks, increasing the
  code readability, debugging and upgrades.
  Path:
  ./contracts/ByTradeToken: transfer(), transferFrom(), approve(),
  increaseAllowance(), decreaseAllowance()
  Recommendation: It is recommended to create a new modifier to
  implement the checks.
  Status: Fixed (Revised commit: 510e568)
