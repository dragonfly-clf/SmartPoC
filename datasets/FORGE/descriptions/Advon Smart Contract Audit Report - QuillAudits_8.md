9. Event emission

 Description

 Changes to state in deployed contracts can be easily tracked using events, especially when logs would need to be kept. The contract allows multiple key variables to be reset and it would be advisable to emit events when this occurs.

 Remediation

 Emit events and index them (where needed) to keep track of critical changes and aid searches for functions that update state.

 Status

 Acknowledged


-----

###### 