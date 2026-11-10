### RTCI - Reward Token Change Inconsistency

**Criticality** Minor / Informative

**Location** TRITON.sol#L2157

**Status** Unresolved

### Description

The contract is currently designed to allow the contract owner to change the distribution

token address using the `updatePayoutToken` method. While this feature offers

flexibility, a key concern is the requirement for a valid pair address between the native token

and the new token address to ensure seamless transactions. Additionally, changing the

reward token address without resetting the internal state of the distributor can lead to

discrepancies, as the variables and calculations are based on the balance and

characteristics of the previous token. This could result in inaccurate reward distributions or

even failures in the distribution process.
```
 function updatePayoutToken(address token) public onlyOwner {
   defaultToken = token;
 }

### Recommendation

```
It is recommended to carefully evaluate the necessity and implications of allowing the

reward token address to be changed. If retaining this feature, the team should implement

safeguards and additional logic to address the potential side-effects of such changes. This

includes verifying the existence of a valid pair address between the native token and the

new token. Alternatively, considering the removal of the option to change the reward token

address could provide a more stable and predictable reward mechanism, thereby

enhancing the reliability and trustworthiness of the contract.


-----

