#### 5.1.4 Hardcoded address
Severity: INFORMATIONAL
Status: ACKNOWLEDGED (GSPI Contract address is verified)
https://bscscan.com/address/0x95CBb5c3f3c23c37D5be5414C591BA3B8B3bbcF1#code
File(s) affected: All

|Attack / Description|Code Snippet|Result/Recommendation|
|---|---|---|
|The current pragma Solidity directive is ^0.5.13; It is recommended to specify a fixed version to ensure that the bytecode produced does not vary between builds. This is especially important if you rely on bytecode-level verification of the code.|Line 1 pragma solidity ^0.5.13;|It is recommended to follow the example(0.5.13), as future compiler versions may handle certain language constructions in a way the developer did need foresee. Not effecting the overall contract functionality.|

|Attack / Description|Code Snippet|Result/Recommendation|
|---|---|---|
|The contract contains unknown address. This address might be used for some malicious activity. Please check|Line 5 ERC20 constant token = ERC20(0xB42e1c3902b85b410334f5fff79cDc51fBeE695 0);|We recommend checking the address. Also, it is required to check the code of the called contract for vulnerabilities.|


-----

hardcoded address and it's
usage.

