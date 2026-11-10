Critical
   1. The mint function allows the Owner to mint tokens without any
    restrictions. It can lead to token supply manipulations.
   Contracts: hoop.sol
   Function: mint
   Recommendation: remove the possibility of unlimited minting.
   Status: fixed.
   2. The setTotalSupply function allows the Owner to change the total
    supply.
   Contracts: hoop.sol
   Function: setTotalSupply
   Recommendation: remove the possibility to change the total supply.
   Status: fixed.
   3. According to the whitepaper, the total supply must be 300 000 000
    tokens. But in the constructor, it was set as 0,0000000003 tokens
    because the decimal multiplier was missed.
   Contracts: hoop.sol
   Function: constructor
   Recommendation: set the right total supply.
   Status: fixed.
   High
   No high severity issues were found.
  Medium
   No medium severity issues were found.
 Low
   No low severity issues were found.

```

-----

```
Conclusion
Smart contracts within the scope were manually reviewed and analyzed with
static analysis tools.
The audit report contains all found security vulnerabilities and other
issues in the reviewed code.
As a result of the audit, security engineers found 3 critical severity
issues.
As a result of the second review, security engineers found that 1 critical
severity issue was resolved, while 2 critical issues remained.
As a result of the third review, security engineers found no issues.

```

-----

```
Disclaimers
Hacken Disclaimer
The smart contracts given for audit have been analyzed in accordance with
the best industry practices at the date of this report, in relation to
cybersecurity vulnerabilities and issues in smart contract source code, the
details of which are disclosed in this report (Source Code); the Source
Code compilation, deployment, and functionality (performing the intended
functions).
The audit makes no statements or warranties on the security of the code. It
also cannot be considered as a sufficient assessment regarding the utility
and safety of the code, bug-free status, or any other statements of the
contract. While we have done our best in conducting the analysis and
producing this report, it is important to note that you should not rely on
this report only — we recommend proceeding with several independent audits
and a public bug bounty program to ensure the security of smart contracts.
Technical Disclaimer
Smart contracts are deployed and executed on a blockchain platform. The
platform, its programming language, and other software related to the smart
contract can have vulnerabilities that can lead to hacks. Thus, the audit
can't guarantee the explicit security of the audited smart contracts.

