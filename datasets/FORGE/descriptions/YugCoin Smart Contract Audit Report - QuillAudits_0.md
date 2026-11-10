1. Infinite mint

 Description

 The owner of this contract can mint an infinite number of tokens because there’s no cap to the supply or check for how much can be minted. The mint function allows only the owner mint any amount of tokens at any time.  Also, minting requires that the owner holds more tokens than intended to mint. Check the mint function for "accountBalance = accountBalance + amount", it is redundant and would not be used.

 Remediation

 Place a cap to the amount of tokens that can be minted, or set up a governance system to approve and accept future mints if intended to happen. Review the logic in the mint function as well.

 Status

 Resolved


-----

###### 