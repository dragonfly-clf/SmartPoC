#### MRM - Missing Revert Messages

**Criticality** Minor / Informative

**Location** FirmSeed.sol#L301

**Status** Unresolved

#### Description

The contract is missing error messages. These missing error messages are making it

difficult to identify and fix the issue. As a result, the users will not be able to find the root

cause of the error.
```
 require((balanceOf(recipient) + finalAmount) <= walletMax);

#### Recommendation

```
The team is advised to carefully review the source code in order to address these issues. To

accelerate the debugging process and mitigate these issues, the team should use more

specific and descriptive error messages.


-----

