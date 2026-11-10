##### 3.3 REDUNDANT CODE

ID: NVE-003                         Location:CarGaiaToken.sol

Severity: Informational                 Category: Business Issues

Likelihood: Informational

Impact: Informational

**Description:**

As shown in Figure 5 below, the DestroyedBlackFunds event declared in the contract

is not used.

_Figure 5 DestroyedBlackFunds event_

**Recommendations:**

Numen Cyber Lab recommends to delete code DestroyedBlackFunds event.

**Result: Pass**

**Fix Result:Fixed**

**The fixed code is as follows:**

Confidential 12