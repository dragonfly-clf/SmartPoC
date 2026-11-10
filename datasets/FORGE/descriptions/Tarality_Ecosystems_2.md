I02. Shadowing State Variable

```
   - `Token.constructor._name shadows:`

      - `ERC20._name`

   - `Token.constructor._symbol shadows:`

      - `ERC20._symbol`

   - `Token.constructor._totalSupply shadows:`

      - `ERC20._totalSupply`
```
  Path: Token.sol : constructor()
  Recommendation: Rename the variables.
  Status: Reported
              www.hacken.io

```