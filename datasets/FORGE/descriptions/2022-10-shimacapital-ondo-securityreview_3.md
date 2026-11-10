4. Solidity compiler optimizations can be problematic|Col2|
|---|---|
|Severity: Informational|Difcfiulty: High|
|Type: Undefni ed Behavior|Finding ID: TOB-ONDO-4|
|Target: Ondo protocol||


##### Description
The Ondo protocol contracts have enabled optional compiler optimizations in Solidity.

There have been several optimization bugs with security implications. Moreover,
[optimizations are actively being developed. Solidity compiler optimizations are disabled by](https://github.com/ethereum/solidity/pull/13535)
default, and it is unclear how many contracts in the wild actually use them. Therefore, it is
unclear how well they are being tested and exercised.

[Security issues due to optimization bugs have occurred in the past. A medium- to](https://docs.soliditylang.org/en/latest/bugs.html)
high-severity bug in the Yul optimizer was introduced in Solidity version 0.8.13 and was
[fixed only recently, in Solidity version 0.8.17. Another medium-severity optimization](https://blog.soliditylang.org/2022/09/08/storage-write-removal-before-conditional-termination/)
[bug—one that caused memory writes in inline assembly blocks to be removed under](https://blog.soliditylang.org/2022/06/15/inline-assembly-memory-side-effects-bug/)
[certain conditions— was patched in Solidity 0.8.15.](https://blog.soliditylang.org/2022/06/15/inline-assembly-memory-side-effects-bug/)

[A compiler audit of Solidity from November 2018 concluded that the optional optimizations](https://blog.zeppelin.solutions/solidity-compiler-audit-8cfc0316a420)
[may not be safe.](https://docs.google.com/document/d/1PZBSCBWBwd6AqWCgXqLnw8FNQ4HRurP5usrXuKuU0a0/edit#heading=h.l6fakub3mvnn)

It is likely that there are latent bugs related to optimization and that new bugs will be
introduced due to future optimizations.

##### Exploit Scenario
A latent or future bug in Solidity compiler optimizations causes a security vulnerability in
the Ondo protocol contracts.

##### Recommendations
Short term, measure the gas savings from optimizations and carefully weigh them against
the possibility of an optimization-related bug.

Long term, monitor the development and adoption of Solidity compiler optimizations to
assess their maturity.

Trail of Bits 29 Ondo Finance Security Assessment


-----

|