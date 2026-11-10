Low
   2. Variable Shadowing.
   The owner variable used in the allowance function shadows the Ownable
   contract’s owner function.
   Contracts:Oracula.sol
   Functions: owner(), approve(address owner, address spender, uint256
   amount), allowance(address owner, address spender)
   3. Boolean Equality.
   Boolean constants can be used directly and do not need to be compared
   to true or false
   Contracts:Oracula.sol
   Functions: _setExcanhePairs(address pair, bool value)
   Recommendation: Avoid using boolean equalities.

```

-----

```
Status:
4. State Variable Visibility not Set (SWC-108).
The visibility for state variables, burnFee, devFee, rewardFee,
maxBurnFee, maxDevFee, maxRewardFee, maximumFee, denominator,
burnAddress, devAddress, rewardAddress are not set.
Contracts:Oracula.sol
Functions: Recommendation: Variables can be specified as being public, internal
or private. Explicitly define visibility for all state variables.
5. State Variables that could be Declared as constant
State variables that don't change their (_decimals, _name, _symbol,
_totalSupply, denominator) value should be declared constant to save
gas.
Contracts:Oracula.sol
Functions: Recommendation:Declare above mentioned variables as constants.
Status:
6. Functions that can be Declared as external
In order to save Gas, public functions that are never called in the
contract should be declared as external.
Contracts: Oracula.sol
Functions: renounceOwnership(), transferOwnership(address newOwner),
increaseAllowance(address spender, uint256 addedValue),
decreaseAllowance(address spender, uint256 subtractedValue),
approve(address owner, address spender, uint256 amount),
allowance(address owner, address spender), transferFrom(address
sender, address recipient, uint256 amount)
Recommendation: Aforementioned should be declared as external.
Status:

```

-----

```
Conclusion
Smart contracts within the scope were manually reviewed and analyzed with
static analysis tools.
The audit report contains all found security vulnerabilities and other
issues in the reviewed code.
As a result of the audit, security engineers found 1 high, 6 low severity
issues.

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

