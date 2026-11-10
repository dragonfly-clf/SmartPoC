▪ Operation Trails & Event Generation|
|---|---|


-----

```
Executive Summary
According to the assessment, the Customer's smart contracts are secured but
could have increased gas fees
 Insecure      Poor secured       Secured       Well-secured
           You are here
Our team performed an analysis of code functionality, manual audit, and
automated checks with Mythril and Slither. All issues found during automated
analysis were manually reviewed, and important vulnerabilities are presented
in the Audit overview section. All found issues can be found in the Audit
overview section.
Security engineers found 1 high, 1 low and 1 informational issues during the
first review.
Security engineers found 1 low and 1 informational issue during the second
review.
   Graph 1. The distribution of vulnerabilities after the first review.

```
```
 Insecure      Poor secured       Secured       Well-secured

```

-----

```
Graph 2. The distribution of vulnerabilities after the second review.

```

-----

```
Severity Definitions
  Risk Level Description
  Critical Critical vulnerabilities are usually straightforward to
         exploit and can lead to assets loss or data
         manipulations.
   High High-level vulnerabilities are difficult to exploit;
         however, they also have a significant impact on smart
         contract execution, e.g., public access to crucial
         functions
   Medium Medium-level vulnerabilities are important to fix;
         however, they can't lead to assets loss or data
         manipulations.
   Low Low-level vulnerabilities are mostly related to
         outdated, unused, etc. code snippets that can't have
         a significant impact on execution
 Lowest / Code Lowest-level vulnerabilities, code style violations,
 Style / Best and info statements can't affect smart contract
  Practice execution and can be ignored.

```
|Risk Level|Description|
|---|---|
|Critical|Critical vulnerabilities are usually straightforward to exploit and can lead to assets loss or data manipulations.|
|High|High-level vulnerabilities are difficult to exploit; however, they also have a significant impact on smart contract execution, e.g., public access to crucial functions|
|Medium|Medium-level vulnerabilities are important to fix; however, they can't lead to assets loss or data manipulations.|
|Low|Low-level vulnerabilities are mostly related to outdated, unused, etc. code snippets that can't have a significant impact on execution|
|Lowest / Code Style / Best Practice|Lowest-level vulnerabilities, code style violations, and info statements can't affect smart contract execution and can be ignored.|


-----

```
Audit overview
   Critical
   No Critical severity issues were found.
   High
  