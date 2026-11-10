#### Low level severity issues

###### 2. Uninformative revert messages in require statements

 Description There is an instance in the codebase where the require statement has ambiguous or imprecise error messages. 
 L94: require(!_INITIALIZED_, "DODO_INITIALIZED");
 Uninformative error messages greatly damage the overall user experience, thus lowering the system’s quality. Consider not only fixing the specific instance mentioned above, but also reviewing the entire codebase to make sure every error message is informative and user- friendly.

 Status: Open

 3. Missing zero address validation

 Description We’ve detected missing zero address validation for the following parameters:  - _FeeAddress in init()   - user in mint()  - newTeam in changeTeamAccount()
 Remediation Consider implementing require statements where appropriate to validate all user-controlled input, including constructor, to avoid the potential for erroneous values to result in unexpected behaviors or wasted gas.

 Status: Open

 0506


-----

