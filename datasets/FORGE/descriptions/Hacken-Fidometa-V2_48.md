27. Hardcoded values

```

-----

```
Hardcoded values make development harder and the code less readable.
decimals value should be defined in one place, and the constant
should be used to introduce it.
Contract: FidoMeta.sol
Function: _getTValues
Variables: _ecoSysFee, _surcharge1
Recommendation: use decimals +(-) value to introduce needed value
dependent on decimals value.
Status: Acknowledged

```

-----

```
Recommendations
  1. Rename variables or write explaining comments to make it easy to
   understand what they are responsible for.
   Contracts: FidoMeta.sol
  2. Provide technical documentation that answers how to build the
   project, run tests for it, etc.
   Contracts: FidoMeta.sol
  3. Provide conscious abstraction levels and restructure the code
   sequentially, disposing of actions and checks.
   Contracts: FidoMeta.sol

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

