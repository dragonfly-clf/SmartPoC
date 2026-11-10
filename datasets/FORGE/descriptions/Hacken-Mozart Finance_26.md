1. Vulnerability: Reward allocation manipulation
   while it’s allowed to set allocPoint of the pool to zero (0), which
   will disallow all rewards and allowing to call set function with
   argument _withUpdate set to false, we see here possible reward
   allocation manipulation by the contract owner
   Partially resolved by moving the ownership to the Timelock contract:
   https://bscscan.com/address/0xbd2a0bb757c7c6ea50f9e7eedb4b4350dec929e
   5#code
  Medium
   No Medium severity issues were found.
 Low
  