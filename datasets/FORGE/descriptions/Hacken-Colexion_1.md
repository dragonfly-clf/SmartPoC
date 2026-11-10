2. Using comparison instead of assignment
   In several places in the code, there is an equality comparison operator
   (==) used instead of the value assignment (=). The compiler will not
   raise any errors because that’s a totally valid construction the only
   warning could be that the result is never used. But from the sight of
   the logic, that’s totally incorrect. 
   As an example let’s see on this statement:

```
```
tOnSale[tId] == false; // When token is being purchased or
auctioned, by default it will be reset to NOT For SALE

```
```
  While the comment says it is “reset to NOT For SALE”, actually nothing
  happens here. Just because it’s a comparison, not an assignment.
  Contracts: Colexion
  Functions: _tTransfer, enableTokenSale, mint
  Recommendation: Please correct comparison and assignment operators
  usages.
  Status: Fixed
   High
  