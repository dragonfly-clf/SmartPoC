Medium
  1. Incorrect token information.
   According to the documentation the token symbol is “HLT” and the
   token address is “0x68dd01dbf335d8767007e342dccfd84027f8da8b”, in the
   code the token symbol is “DHLT” and the provided token address is
   “0x7f389b5fb10b85b2dcdd7228bc8695855da70d79”.
   The contract should match the information from the documentation.
   Contracts: DeHealthToken.sol
   Function: initialize
   Recommendation: ensure the code meets the documentation requirements.
   Status: Fixed

```

-----

```
