#### L06 - Missing Events Access Control

**Criticality** Minor / Informative

**Location** Karma.sol#L681

**Status** Unresolved

#### Description

Events are a way to record and log information about changes or actions that occur within a

contract. They are often used to notify external parties or clients about events that have

occurred within the contract, such as the transfer of tokens or the completion of a task.

There are functions that have no event emitted, so it is difficult to track off-chain changes.
```
 feeExemptSetter = _feeExemptSetter

#### Recommendation

```
To avoid this issue, it's important to carefully design and implement the events in a contract,

and to ensure that all required events are included. It's also a good idea to test the contract

to ensure that all events are being properly triggered and logged.

By including all required events in the contract and thoroughly testing the contract's

functionality, the contract ensures that it performs as intended and does not have any

missing events that could cause issues.


-----

