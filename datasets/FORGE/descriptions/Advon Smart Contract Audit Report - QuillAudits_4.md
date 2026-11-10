5. Null token transfers

 Description

 On token transfers, the arithmetic calculations carried out determine how many tokens will be locked and how many can be transferred to users. Although the checks are implemented, the transfers from the caller to the msg.sender and the token do not happen

 Remediation

 Ensure the arithmetic checks are accurate, and tokens are transferred from the caller to the appropriate receivers.

 Status

 Partially Resolved


-----

###### 