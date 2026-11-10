#### Low level severity issues

###### 5. Tokens can be burned at the Owner behest Line No: 213

 Description Generally, the functionality of minting and burning of tokens goes hand in hand. The MINT_FORBIDDEN is being used to decide whether the contract can mint more tokens or not. However, such restriction is not in the burn function; the owner can burn tokens anytime. 

 Remediation Properly analyze requirements and consequences for burning tokens.

 Status: Open

 0507


-----

###### 6. Lack of unit tests.

 Description The code is taken from BscScan, so we are under the assumption that  there are no unit tests for the codebase. Contracts meant to handle thousands of user funds should have appropriate testing and coverage.

 Remediation Implement unit tests with at least 98% coverage.

 Status: Open

