#### 5.1.2 Wrong import of OpenZeppelin library
Severity: MEDIUM
Status: Acknowledged
File(s) affected: All

**Attack / Description** **Code Snippet**
In the current `SafeMath, IERC20`
implementation, OpenZeppelin
files are added directly into the
code. This
violates OpenZeppelin’s MIT
license, which requires the
license and copyright notice to
be included if its code is used.
Moreover, updating code
manually is error-prone.

### LOW ISSUES

During the audit, Chainsulting’s experts found no Low issues in the code of the smart contract.

|Attack / Description|Code Snippet|Result/Recommendation|
|---|---|---|
|In the current implementation, OpenZeppelin files are added directly into the code. This violates OpenZeppelin’s MIT license, which requires the license and copyright notice to be included if its code is used. Moreover, updating code manually is error-prone.|SafeMath, IERC20|We highly recommend using npm (import "@openzeppelin/contracts/..) in order to guarantee that original OpenZeppelin contracts are used with no modifications. This also allows for any bug-fixes to be easily integrated into the codebase.|


-----

### INFORMATIONAL ISSUES

