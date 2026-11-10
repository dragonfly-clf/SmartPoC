Medium Severity Issues

 2. Privileged account transfers

 Description

 If renouncing privileges is not done appropriately, the current beneficiary can renounce their privileges and still be excluded from fees while the new beneficiary will be able to collect fees and still retain same privileges. This can result in loss of revenue for the client.

 Remediation

 Properly deal with privilege account transfers in setFeesAddress(), setBuybackAddress(), setMarketingAddress(), setDevelopmentAddress and setLPtokenReciver().

 Status

 Acknowledged


-----

###### 3. Input sanitization

 Description

 Majority of functions could behave irregularly because of the lack of input validation.

 Remediation

 Input validation could be done by including require checks at the beginning of the methods to restrict the values that can be passed in and thereby the possibility of unexpected values being obtained during function calls.

 Status

 Acknowledged

 4. Missing test cases

 Description

 The codebase lacks unit test coverage. It is advisable to have test coverage greater than 95% of the codebase to reduce unexpected functionality and help fuzz test as many invariants as possible.

 Remediation

 Include unit tests for the codebase.

 Status

 Partially Resolved

 