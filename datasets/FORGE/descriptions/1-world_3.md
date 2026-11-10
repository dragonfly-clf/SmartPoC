#### MFI - Misleading Function Implementation

**Criticality** Medium

**Location** contracts/WorldToken.sol#L1160

**Status** Unresolved

#### Description

The `eventParticipate` function provides a fee-free transfer mechanism for tokens.

Given the presence of both options within the contract, users might opt to utilize this

function for their token transfers instead of the designated `transfer` or

`transferFrom` functions. Consequently, the fee mechanism could potentially lose its

relevance.
```
 function eventParticipate(address to, uint256 amount) external {
   _transfer_simple(msg.sender, to, amount);
 }

#### Recommendation

```
The team is advised to take these segments into consideration and either remove them if

they serve no purpose or rewrite them so that they follow the team's business logic. For

instance, if the function was not intended to be publicly accessible then the team should

add proper guards to avoid non-authorized calls.


-----

