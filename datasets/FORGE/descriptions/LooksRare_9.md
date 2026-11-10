10. Solidity compiler optimizations can be problematic|Col2|
|---|---|
|Severity: Informational|Difficulty: Low|
|Type: Undefined Behavior|Finding ID: TOB-LR-10|
|Target: LooksRare protocol||


#### Description
The LooksRare contracts have enabled optional compiler optimizations in Solidity.

There have been several optimization bugs with security implications. Moreover,
[optimizations are actively being developed . Solidity compiler optimizations are disabled by](https://github.com/ethereum/solidity/pull/11093)
default, and it is unclear how many contracts in the wild actually use them. Therefore, it is
unclear how well they are being tested and exercised.

[High-severity security issues due to optimization bugs have occurred in the past . A](https://solidity.readthedocs.io/en/v0.7.0/bugs.html)
[high-severity bug in the emscripten -generated solc-js compiler used by Truffle and](https://docs.google.com/document/d/1PZBSCBWBwd6AqWCgXqLnw8FNQ4HRurP5usrXuKuU0a0/edit#heading=h.csz7fns3yza3)
Remix persisted until late 2018. The fix for this bug was not reported in the Solidity
CHANGELOG. Another high-severity optimization bug resulting in incorrect bit shift results
[was patched in Solidity 0.5.6 . More recently, another bug due to the incorrect caching of](https://github.com/ethereum/solidity/releases/tag/v0.5.6)
```
 keccak256 was reported.

```
[A compiler audit of Solidity from November 2018 concluded that the optional optimizations](https://blog.zeppelin.solutions/solidity-compiler-audit-8cfc0316a420)
[may not be safe .](https://docs.google.com/document/d/1PZBSCBWBwd6AqWCgXqLnw8FNQ4HRurP5usrXuKuU0a0/edit#heading=h.l6fakub3mvnn)

It is likely that there are latent bugs related to optimization and that new bugs will be
introduced due to future optimizations.

#### Exploit Scenario
A latent or future bug in Solidity compiler optimizations—or in the Emscripten transpilation
to solc-js —causes a security vulnerability in the LooksRare contracts.

#### Recommendations
Short term, measure the gas savings from optimizations and carefully weigh them against
the possibility of an optimization-related bug.

Long term, monitor the development and adoption of Solidity compiler optimizations to
assess their maturity.

Trail of Bits 35 LooksRare Security Assessment


-----

|