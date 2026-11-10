#### FO - Function Optimization

**Criticality** Minor / Informative

**Location** Guitarist.sol#L1676,1685

**Status** Unresolved

#### Description

The current implementation of both the `toggleReveal` and

`toggle_public_mint_status` functions in the contract utilizes an `if-else`

statement to toggle the state of the `revealed` and `public_mint_status` variables

respectively. However, this approach, while functional, is more verbose than necessary.

Each function checks a boolean condition and then explicitly sets the variable to true or

false based on this condition. This results in additional lines of code that essentially

replicate the standard behavior of a boolean toggle.
```
   function toggleReveal() external onlyOwner {
      if(revealed==false){
        revealed = true;
      }else{
        revealed = false;
      }
   }
   function toggle_public_mint_status() external onlyOwner {
      if(public_mint_status==false){
        public_mint_status = true;
      }else{
        public_mint_status = false;
      }
   }

#### Recommendation

```
It is recommended to refactor both functions for improved conciseness and clarity. The

`toggleReveal` function can be simplified to a single line: `revealed = !revealed;`

. Similarly, the `toggle_public_mint_status` function can be refactored to


-----

```
public_mint_status = !public_mint_status; . These changes leverages the

```
logical NOT operator (!) to flip the boolean state of the variable, thereby achieving the same

functionality in a more streamlined and readable manner. This refactoring not only enhances

code readability but also marginally optimizes the contract by reducing the number of

operations required.


-----

