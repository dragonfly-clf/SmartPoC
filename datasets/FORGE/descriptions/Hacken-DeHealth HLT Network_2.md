Low
1. Functions that can be declared as external.
  There are public functions in the contracts that are not used
  internally.
  “External” visibility uses less Gas.
  Contracts: DeHealthToken.sol
  Functions: version, pause, unpause, setGuardContract, __loadBalances,
  Recommendation: replace the visibilities to “external”.
  Status: New
2. Unlocked pragma.
  Contracts with unlocked pragmas may be deployed by the latest
  compiler, which may have higher risks of undiscovered bugs.
  Contracts should be deployed with the same compiler version that has
  been tested thoroughly.
  Contracts: DeHealthToken.sol, DProxy.sol
  Function:   Recommendation: lock pragmas to a specific compiler version.
  Status: New

```

-----

```
Disclaimers
Hacken Disclaimer
The smart contracts given for audit have been analyzed by the best industry
practices at the date of this report, with cybersecurity vulnerabilities
and issues in smart contract source code, the details of which are
disclosed in this report (Source Code); the Source Code compilation,
deployment, and functionality (performing the intended functions).
The audit makes no statements or warranties on the security of the code. It
also cannot be considered a sufficient assessment regarding the utility and
safety of the code, bug-free status, or any other contract statements.
While we have done our best in conducting the analysis and producing this
report, it is important to note that you should not rely on this report
only — we recommend proceeding with several independent audits and a public
bug bounty program to ensure the security of smart contracts.
Technical Disclaimer
Smart contracts are deployed and executed on a blockchain platform. The
platform, its programming language, and other software related to the smart
contract can have vulnerabilities that can lead to hacks. Thus, the audit
cannot guarantee the explicit security of the audited smart contracts.

