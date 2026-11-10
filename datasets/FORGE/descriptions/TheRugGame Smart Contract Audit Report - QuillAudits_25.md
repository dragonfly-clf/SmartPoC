5. GameStartTime set every time

 Description

 The gamestartTime was being set in the createToken each time. This was not as per the business logic requirement.

 Remediation

 According to the new changes in the implementation logic, the setting of the value to gameStartTime was moved to an initialization function instead.

 Status

 Resolved