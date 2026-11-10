## QSP-9 Allowance Double-Spend Exploit

#### Severity: Informational

 Status: Mitigated

###### File(s) affected: ERC20RFT.sol

 Description: As it presently is constructed, the contract is vulnerable to the allowance double-spend exploit, as with other ERC20 tokens.

 Exploit Scenario: An example of an exploit goes as follows:

#### 1. Alice allows Bob to transfer N amount of Alice's tokens (N>0) by calling the approve() method on Token smart contract (passing Bob's address and N as method

 arguments)


#### 2. After some time, Alice decides to change from N to M M>0( ) the number of Alice's tokens Bob is allowed to transfer, so she calls the approve() method again, this time

 passing Bob's address and M as method arguments


#### 3. Bob notices Alice's second transaction before it was mined and quickly sends another transaction that calls the transferFrom() method to transfer N Alice's tokens

 somewhere

 4. If Bob's transaction will be executed before Alice's transaction, then Bob will successfully transfer N Alice's tokens and will gain an ability to transfer another M tokens

 5. Before Alice notices any irregularities, Bob calls transferFrom() method again, this time to transfer M Alice's tokens.

###### Recommendation: The exploit (as described above) is mitigated through use of functions that increase/decrease the allowance relative to its current value, such as increaseAllowance and
```
decreaseAllowance.
 Pending community agreement on an ERC standard that would protect against this exploit, we recommend that developers of applications dependent on approve() / transferFrom() should keep in mind that they have to set allowance to 0 first and verify if it was used before setting the new value. Teams who decide to wait for such a standard should make these recommendations to app developers who work with their token contract.

```

###### Update: From dev team: We have added notices about this exploit in the documentation for Rari Fund Token (RFT) in API.md and USAGE.md.

