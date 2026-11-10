14. Use of legacy openssl version in solidity-coverage plugin|Col2|
|---|---|
|Severity: Informational|Difficulty: Undetermined|
|Type: Patching|Finding ID: TOB-LR-14|
|Target: LooksRare protocol||


#### Description
The LooksRare codebase uses a version of solidity-coverage that relies on a legacy
version of openssl to run. While this plugin does not alter protocol contracts deployed to
production, the use of outdated security protocols anywhere in the codebase may be risky
or prone to errors.
```
 Error in plugin solidity-coverage: Error: error:0308010C:digital envelope
 routines::unsupported

```
_Figure 14.1: Error raised by npx hardhat coverage_

#### Recommendations
Short term, refactor the code to use a new version of openssl to prevent the exploitation
of openssl vulnerabilities.

Long term, avoid using outdated or legacy versions of dependencies.

Trail of Bits 43 LooksRare Security Assessment


-----

|