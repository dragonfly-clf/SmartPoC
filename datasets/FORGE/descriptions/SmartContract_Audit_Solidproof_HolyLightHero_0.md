## Vulnerability & Risk Level

###### Risk represents the probability that a certain source-threat will exploit vulnerability, and the impact of that event on the organization or system. Risk Level is computed based on CVSS version 3.0.


Level Value Vulnerability Risk (Required Action)

A vulnerability that
can disrupt the
contract functioning

Immediate action to

##### Critical 9 - 10 in a number of

reduce risk level.

scenarios, or creates a
risk that the contract
may be broken.

A vulnerability that
affects the desired
outcome when using Implementation of

##### High 7 – 8.9 a contract, or provides corrective actions as

the opportunity to soon aspossible.
use a contract in an
unintended way.

A vulnerability that
could affect the

Implementation of

desired outcome of

##### Medium 4 – 6.9 corrective actions in a

executing the

certain period.

contract in a specific
scenario.

A vulnerability that
does not have a

Implementation of

significant impact on

certain corrective

##### Low 2 – 3.9 possible scenarios for

actions or accepting

the use of the

the risk.

contract and is
probably subjective.

A vulnerability that
have informational An observation that

##### Informational 0 – 1.9 character but is not does not determine a

effecting any of the level of risk
code.

6

|Level Critical|Value 9 - 10|Vulnerability A vulnerability that can disrupt the contract functioning in a number of scenarios, or creates a risk that the contract may be broken.|Risk (Required Action) Immediate action to reduce risk level.|
|---|---|---|---|
|High|7 – 8.9|A vulnerability that affects the desired outcome when using a contract, or provides the opportunity to use a contract in an unintended way.|Implementation of corrective actions as soon aspossible.|
|Medium|4 – 6.9|A vulnerability that could affect the desired outcome of executing the contract in a specific scenario.|Implementation of corrective actions in a certain period.|
|Low|2 – 3.9|A vulnerability that does not have a significant impact on possible scenarios for the use of the contract and is probably subjective.|Implementation of certain corrective actions or accepting the risk.|
|Informational|0 – 1.9|A vulnerability that have informational character but is not effecting any of the code.|An observation that does not determine a level of risk|


Level Value Vulnerability Risk (Required Action)

A vulnerability that
can disrupt the
contract functioning

Immediate action to

##### Critical 9 - 10 in a number of

reduce risk level.

scenarios, or creates a
risk that the contract
may be broken.

A vulnerability that
affects the desired
outcome when using Implementation of

##### High 7 – 8.9 a contract, or provides corrective actions as

the opportunity to soon aspossible.
use a contract in an
unintended way.

A vulnerability that
could affect the

Implementation of

desired outcome of

##### Medium 4 – 6.9 corrective actions in a

executing the

certain period.

contract in a specific
scenario.

A vulnerability that
does not have a

Implementation of

significant impact on

certain corrective

##### Low 2 – 3.9 possible scenarios for

actions or accepting

the use of the

the risk.

contract and is
probably subjective.

A vulnerability that
have informational An observation that

##### Informational 0 – 1.9 character but is not does not determine a

effecting any of the level of risk
code.


##### High


##### Medium


-----

## Auditing Strategy and Techniques Applied

###### Throughout the review process, care was taken to evaluate the repository for security-related issues, code quality, and adherence to specification and best practices. To do so, reviewed line-by-line by our team of expert pentesters and smart contract developers, documenting any issues as there were discovered.


#### Methodology


The auditing process follows a routine series of steps:
1. Code review that includes the following:

i) Review of the specifications, sources, and instructions provided to SolidProof
to make sure we understand the size, scope, and functionality of the smart
contract.
ii) Manual review of code, which is the process of reading source code line-by
line in an attempt to identify potential vulnerabilities.
iii) Comparison to specification, which is the process of checking whether the

code does what the specifications, sources, and instructions provided to
SolidProof describe.

2. Testing and automated analysis that includes the following:

i) Test coverage analysis, which is the process of determining whether the test
cases are actually covering the code and how much code is exercised when
we run those test cases.
ii) Symbolic execution, which is analysing a program to determine what inputs

causes each part of a program to execute.

3. Best practices review, which is a review of the smart contracts to improve efficiency,
effectiveness, clarify, maintainability, security, and control based on the established
industry and academic practices, recommendations, and research.

4. Specific, itemized, actionable recommendations to help you take steps to secure

your smart contracts.

7


###### pentesters and smart contract developers, documenting any issues as there were discovered.


#### Methodology


The auditing process follows a routine series of steps:
Code review that includes the following:

i) Review of the specifications, sources, and instructions provided to SolidProof
to make sure we understand the size, scope, and functionality of the smart
contract.
ii) Manual review of code, which is the process of reading source code line-by-

line in an attempt to identify potential vulnerabilities.
iii) Comparison to specification, which is the process of checking whether the

code does what the specifications, sources, and instructions provided to
SolidProof describe.

Testing and automated analysis that includes the following:

i) Test coverage analysis, which is the process of determining whether the test
cases are actually covering the code and how much code is exercised when
we run those test cases.
ii) Symbolic execution, which is analysing a program to determine what inputs

causes each part of a program to execute.

Best practices review, which is a review of the smart contracts to improve efficiency,
effectiveness, clarify, maintainability, security, and control based on the established
industry and academic practices, recommendations, and research.

4. Specific, itemized, actionable recommendations to help you take steps to secure

your smart contracts.


-----

#### Used Code from other Frameworks/Smart Contracts (direct imports)


###### Imported packages:


8


-----

#### Tested Contract Files

###### This audit covered the following files listed below with a SHA-1 Hash.

 A file with a different Hash has been modified, intentionally or otherwise, after the security review. A different Hash could be (but not necessarily) an indication of a changed condition or potential vulnerability that was not within the scope of this review.


##### v1.0


9


-----

## Metrics

#### Source Lines

##### v1.0


#### Risk Level

##### v1.0


#### Risk Level


10


-----

#### Capabilities


##### Components

**Version** **Contracts** **Libraries** **Interfaces** **Abstract**

1.0 3 1 1 0

##### Exposed Functions

###### This section lists functions that are explicitly declared public or payable. Please note that getter methods for public stateVars are not included.


**Version** **Public** **Payable**

1.0 28 0

**Version** **External** **Internal** **Private** **Pure** **View**

1.0 20 39 0 8 17

##### State Variables

**Version** **Total** **Public**

1.0 7 3

##### Capabilities


**Has**

**Solidity** **Experim** **Can** **Uses** **Destroya**

**Version** **Versions** **ental** **Receive** **Assembl** **ble**

**observed** **Features** **Funds** **y** **Contract**

**s**

1.0 0.5.16

11

|Version|Contracts|Libraries|Interfaces|Abstract|
|---|---|---|---|---|
|1.0|3|1|1|0|

|Version|Public|Payable|
|---|---|---|
|1.0|28|0|

|Version|External|Internal|Private|Pure|View|
|---|---|---|---|---|---|
|1.0|20|39|0|8|17|

|Version|Total|Public|
|---|---|---|
|1.0|7|3|

|Version|Solidity Versions observed|Experim ental Features|Can Receive Funds|Uses Assembl y|Has Destroya ble Contract s|
|---|---|---|---|---|---|
|1.0|0.5.16|||||


3 1 1

##### Exposed Functions

###### This section lists functions that are explicitly declared public or payable. Please note that getter methods for public stateVars are not included.


**Version** **Public** **Payable**

28 0

**Version** **External** **Internal** **Private** **Pure** **View**

20 39 0 8

##### State Variables

**Version** **Total** **Public**

7 3

##### Capabilities


**Has**

**Solidity** **Experim** **Can** **Uses** **Destroya**

**Version** **Versions** **ental** **Receive** **Assembl** **ble**

**observed** **Features** **Funds** **y** **Contract**

**s**

0.5.16


-----

#### Inheritance Graph

##### v1.0


12


-----

#### CallGraph

##### v1.0


13


-----

#### Scope of Work/Verify Claims

###### The above token Team provided us with the files that needs to be tested (Github, Bscscan, Etherscan, files, etc.). The scope of the audit is the main contract (usual the same name as team appended with .sol).

 We will verify the following claims:

 1. Correct implementation of Token standard
 2. Deployer cannot mint any new tokens
 3. Deployer cannot burn or lock user funds
 4. Deployer cannot pause the contract
 5. Approve function is restricted
 6. Overall checkup (Smart Contract Security)


##### Correct implementation of Token standard


**Function** **Description** **Exist** **Tested** **Verified**

provides information about the total
TotalSupply

token supply ✓ ✓ ✓

provides account balance of the
BalanceOf

owner's account ✓ ✓ ✓

executes transfers of a specified

Transfer number of tokens to a specified

### ✓ ✓ ✓
address

executes transfers of a specified

TransferFrom number of tokens from a specified

### ✓ ✓ ✓
address

allow a spender to withdraw a set

Approve number of tokens from a specified

### ✓ ✓ ✓
account

returns a set number of tokens from
Allowance

a spender to the owner ✓ ✓ ✓

14

|Function|Description|Exist|Tested|Verified|
|---|---|---|---|---|
|TotalSupply|provides information about the total token supply|✓|✓|✓|
|BalanceOf|provides account balance of the owner's account|✓|✓|✓|
|Transfer|executes transfers of a specifei d number of tokens to a specifei d address|✓|✓|✓|
|TransferFrom|executes transfers of a specified number of tokens from a specifei d address|✓|✓|✓|
|Approve|allow a spender to withdraw a set number of tokens from a specifei d account|✓|✓|✓|
|Allowance|returns a set number of tokens from a spender to the owner|✓|✓|✓|


###### Deployer cannot mint any new tokens
 Deployer cannot burn or lock user funds
 4. Deployer cannot pause the contract
 Approve function is restricted
 Overall checkup (Smart Contract Security)


##### Correct implementation of Token standard


**Function** **Description** **Exist** **Tested** **Verified**

provides information about the total
TotalSupply

token supply ✓ ✓ ✓

provides account balance of the
BalanceOf

owner's account ✓ ✓ ✓

executes transfers of a specified

Transfer number of tokens to a specified

### ✓ ✓ ✓
address

executes transfers of a specified

TransferFrom number of tokens from a specified

### ✓ ✓ ✓
address

allow a spender to withdraw a set

Approve number of tokens from a specified

### ✓ ✓ ✓
account

returns a set number of tokens from
Allowance

a spender to the owner ✓ ✓ ✓


-----

##### Write functions of contract
 v1.0


15


-----

|Deployer cannot mint any new tokens|Col2|Col3|Col4|
|---|---|---|---|
|Name|Exist|Tested|Status|
|Deployer cannot mint|✓|✓|✘|
|Max / Total Supply|100.000.000|||


###### Comments:

##### v1.0

###### • Deployer can mint new tokens


###### Comments:

 Deployer can mint new tokens


16


-----

##### Deployer cannot burn or lock user funds


**Name**

Deployer cannot lock

Deployer cannot burn

###### Comments:

##### v1.0

###### • Everyone can burn tokens

|Name|Exist|Tested|Status|
|---|---|---|---|
|Deployer cannot lock|✓|✓|✓|
|Deployer cannot burn|✓|✓|✘|


###### Comments:

 Everyone can burn tokens


17


-----

|Deployer cannot pause the contract|Col2|Col3|Col4|
|---|---|---|---|
|Name|Exist|Tested|Status|
|Deployer cannot pause|-|-|-|


18


-----

|External approve function is restricted|Col2|Col3|Col4|
|---|---|---|---|
|Name|Exist|Tested|Status|
|External approve cannot be called without restriction|-|-|-|


19


-----

##### Overall checkup (Smart Contract Security)


**Tested** **Verified**
### ✓ ✓

###### Legend

|Tested|Verified|
|---|---|
|✓|✓|

|Attribute|Symbol|
|---|---|
|Verfified / Checked|✓|
|Partly Verifei d|⚑|
|Unverifei d / Not checked|✘|
|Not available|-|


**Attribute** **Symbol**

Verfified / Checked
### ✓

Partly Verified
```
               ⚑

```
Unverified / Not checked
### ✘

Not available
### 

20


-----

#### Modifiers and public functions

##### v1.0


###### Please check if an OnlyOwner or similar restrictive modifier has been forgotten.


21


###### Please check if an OnlyOwner or similar restrictive modifier has been forgotten.


-----

#### Source Units in Scope

##### v1.0

|Legend|Col2|
|---|---|
|Attribute|Description|
|Lines|total lines of the source unit|
|nLines|normalized lines of the source unit (e.g. normalizes functions spanning multiple lines)|
|nSLOC|normalized source lines of code (only source-code lines; no comments, no blank lines)|
|Comment Lines|lines containing single or block comments|
|Complexity Score|a custom complexity score derived from code statements that are known to introduce code complexity (branches, loops, calls, external interfaces, ...)|


Attribute Description

total lines of the source unit

normalized lines of the source unit (e.g. normalizes functions
spanning multiple lines)

normalized source lines of code (only source-code lines; no
comments, no blank lines)

Comment Lines lines containing single or block comments

a custom complexity score derived from code statements that

Complexity Score are known to introduce code complexity (branches, loops, calls,

external interfaces, ...)


22


-----

