##### 3.1 TRANSACTION BLACKLIST CHECK

ID: NVE-001                         Location: CarGaiaToken.sol

Severity: High                       Category: Business Issues

Likelihood: High

Impact: High

**Description:**

As shown in figure 1 below, The modifier isBlackListed only checks whether the caller is a

blacklist address.

 transfer

As shown in figure 2 below, When the user calls the transfer function to transfer tokens, it only

checks whether the caller is a blacklist address, However there is not check on the “_to”

address.

 transferFrom

As shown in figure 3 below，When the user calls the transferFrom function to transfer tokens,

it only checks whether the caller is a blacklist address, However there is no check on the

“_from” address and “_to” address. Even if _form is a blacklist address, tokens can be

transferred out.

_Figure 1 modifier function_

Confidential 8


-----

**Recommendations:**

Numen Cyber Lab recommends to modify the code logic.

**Result: PASS**

**Fix Result: Fixed(After communicating with the project party, the “from” address**

blacklist check in the transferFrom function has been fixed and the blacklist address

can receive tokens as normal logic).

**The fixed code is as follows:**

Confidential 9


-----

