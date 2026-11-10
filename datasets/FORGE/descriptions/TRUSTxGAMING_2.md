####  Low Severity Issues

###### 2. Out of gas

 Issue:

 • The function airdrop() uses the loop to iterate through addresses list.
 Function will be aborted with OUT_OF_GAS exception if there will be a long addresses list.
 • The function multiSender() uses the loop to iterate through _recipients 
 and _values list. It also could be aborted with OUT_OF_GAS exception if there will be a long lists.

 Recommendation:
 Check that the array length is not too big.

#### Owner privileges (In the period when the owner is not renounced)

              - Owner can pause/unpause the contact.

              - Owner can burn tokens from any address.

              - Owner can freeze accounts.

              - Owner can withdraw BEP20 tokens from contract balance.