3. Project dependencies contain vulnerabilities|Col2|
|---|---|
|Severity: Medium|Difficulty: Low|
|Type: Patching|Finding ID: TOB-LR-3|
|Target: LooksRare protocol||


#### Description
Although dependency scans did not identify a direct threat to the project under review, npm
and yarn audit identified a dependency with a known vulnerability. Due to the sensitivity
of the deployment code and its environment, it is important to ensure that dependencies
are not malicious. Problems with dependencies in the JavaScript community could have a
significant effect on the repositories under review. The output below details the high
severity issue:

**CVE ID** **Description** **Dependency**

[CVE-2021-23358](https://nvd.nist.gov/vuln/detail/CVE-2021-23358) Vulnerability to arbitrary code `underscore`

injection in underscore

_Figure 3.1: An advisory affecting underscore, a LooksRare dependency_

#### Exploit Scenario
Alice installs the dependencies of an in-scope repository on a clean machine. Unbeknownst
to Alice, a dependency of the project has become malicious or exploitable. Alice
subsequently uses the dependency, disclosing sensitive information to an unknown actor.

#### Recommendations
Short term, ensure that LooksRare protocol dependencies are up to date. Several node
modules have been documented as malicious because they execute malicious code when
installing dependencies to projects. Keep modules current and verify their integrity after
installation.

Long term, integrate automated dependency auditing into the development workflow. If a
dependency cannot be updated when a vulnerability is disclosed, ensure the code does not
use and is not affected by the vulnerable functionality of the dependency.

Trail of Bits 24 LooksRare Security Assessment

|CVE ID|Description|Dependency|
|---|---|---|
|CVE-2021-23358|Vulnerability to arbitrary code injection in underscore|underscore|


-----

|