#### MOEE - Misleading Ownership Event Emission

**Criticality** Minor / Informative

**Location** Token.sol#L295

**Status** Unresolved

#### Description

The contract contains a potential issue with the emission of the OwnershipTransferred

event. The issue arises when the methods transferOwnership, renounceOwnership, and

lockOwnership are called. In all cases, the contract emits an OwnershipTransferred event,

but the emitted event's parameters may lead to a misleading interpretation.

In particular, when the lockOwnership method is invoked, it emits an OwnershipTransferred

event with the zero address as the new owner. However, in this context, the ownership is

not permanently renounced but rather temporarily moved to the zero address and is

expected to revert back once the ownership time locker expires. This could potentially lead

users and decentralized applications (Dapps) to misinterpret the event as the ownership

being permanently renounced, causing confusion and misalignment with the actual contract

behavior.


-----

#### Recommendation

To improve transparency and prevent misleading interpretations, we recommend

differentiating between the temporary transfer of ownership in the `lockOwnership`

method and the permanent renouncement of ownership in the `renounceOwnership`

method. The team could modify the `lockOwnership` method to emit a new event, such

as `OwnershipLocked, to clearly indicate the temporary transfer of ownership to the zero`

address. Ensure that the event description includes relevant information, such as the time

when the ownership is expected to revert.

By implementing these changes, the contract will provide more accurate and user-friendly

event emissions, reducing the risk of misinterpretation and confusion among users and

Dapps. This approach will also align the events with the actual behavior of the contract,

enhancing its overall usability and transparency.


-----

