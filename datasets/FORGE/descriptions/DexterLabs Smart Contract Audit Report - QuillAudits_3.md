Informational Issues

 5. Event emission

 Description

 Some of the contract functions that update the vault’s state do not emit events when called. It is advisable for ease of tracking changes on the blockchain to emit events. The functions that change state should have events emitted when called.

 Remediation

 Emit events for these state changes for ease of tracking and logging.

 Status

 Acknowledged