A3. Incorrect require statement in init()

 Description

 Incorrect require statement due to which init reverts on setting IMO end date in any time in future.

 Instead his should be require(_imoenddate > getBlocktimestamp(),"End time cannot be old time");

 Remediation

 It is advised to make the changes as suggested above

 Status

 Resolved

 