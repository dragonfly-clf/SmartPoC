4. Code and documentation inconsistency.
  Contracts: POC_ERC20.sol, POC_BEP20.sol
  Functions: _fee_rate_set

```

-----

```
According to documentation maximum fee should be 100%, but contracts
allow to set it up to 1000%.
Recommendation: update contracts or documentation
Status: fixed

```

-----

```
Conclusion
Smart contracts within the scope were manually reviewed and analyzed with
static analysis tools. 
The audit report contains all found security vulnerabilities and other issues
in the reviewed code.
As a result of the audit, security engineers found 1 high and 4 low severity
issues.
After the second review security engineers found that some contracts were
slightly changed. Therefore found 1 medium and 1 low severity issue.
After the third review security engineers found that all issues were fixed.

```

-----

```
Disclaimers
Hacken Disclaimer
The smart contracts given for audit have been analyzed in accordance with
the best industry practices at the date of this report, in relation to
cybersecurity vulnerabilities and issues in smart contract source code, the
details of which are disclosed in this report (Source Code); the Source Code
compilation, deployment, and functionality (performing the intended
functions).
The audit makes no statements or warranties on the security of the code. It
also cannot be considered as a sufficient assessment regarding the utility
and safety of the code, bug-free status, or any other statements of the
contract. While we have done our best in conducting the analysis and producing
this report, it is important to note that you should not rely on this report
only — we recommend proceeding with several independent audits and a public
bug bounty program to ensure the security of smart contracts.
Technical Disclaimer
Smart contracts are deployed and executed on a blockchain platform. The
platform, its programming language, and other software related to the smart
contract can have vulnerabilities that can lead to hacks. Thus, the audit
can't guarantee the explicit security of the audited smart contracts.

