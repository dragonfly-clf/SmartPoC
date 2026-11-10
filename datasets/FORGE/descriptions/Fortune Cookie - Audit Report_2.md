#### Low severity issues

**1.** **Comparison to boolean Constant**
Line no: 580
**Description:**
Boolean constants can directly be used in conditional statements or require statements.
Therefore, it's not considered a better practice to explicitly use TRUE or FALSE in the
**require statements.**

**Recommendation:**
The equality to boolean constants must be removed from the above-mentioned line.

**2.** **Absence of Zero Address Validation**
**Description:**
The FortuneCookie V2 contract includes quite a few functions that update some of the
imperative addresses in the contract like lastWinner_address,uniswapV2Pair etc.
However, during the automated testing of the contact it was found that no Zero Address
Validation is implemented on the following functions while updating the address state
variables of the contract:

**●** **addWinner**

**●** **setUniswapPair**

**Recommendation:**
A require statement should be included in such functions to ensure no zero address is
passed in the arguments.

**3.** **External Visibility should be preferred**
**Description:**
Those functions that are never called throughout the contract should be marked as
**external visibility instead of public visibility.**
This will effectively result in Gas Optimization as well.

This audit does not provide a security or correctness guarantee of the audited smart contract. Securing smart contracts is a
multistep process, therefore running a bug bounty program as a complement to this audit is strongly recommended.