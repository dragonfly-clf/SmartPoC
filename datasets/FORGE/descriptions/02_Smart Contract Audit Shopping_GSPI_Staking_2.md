#### 5.1.3 A floating pragma is set
Severity: INFORMATIONAL
Status: Fixed
File(s) affected: All

**Attack / Description** **Code Snippet**
The current pragma Solidity Line 1
directive is ^0.5.13; It is pragma solidity ^0.5.13;
recommended to specify a
fixed version to ensure that the
bytecode produced does not
vary between builds. This is
especially important if you rely
on bytecode-level verification
of the code.

