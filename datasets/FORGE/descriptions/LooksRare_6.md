7. Contracts used as dependencies do not track upstream changes|Col2|
|---|---|
|Severity: Low|Difficulty: Low|
|Type: Patching|Finding ID: TOB-LR-7|
|Target: contracts/libraries/SignatureChecker.sol||


#### Description
The LooksRare codebase uses a third-party contract, SignatureChecker, but the
LooksRare documentation does not specify which version of the contract is used or
whether it was modified. This indicates that the LooksRare protocol does not track
upstream changes in contracts used as dependencies. Therefore, the LooksRare contracts
may not reliably reflect updates or security fixes implemented in their dependencies, as
those updates must be manually integrated into the contracts.

#### Exploit Scenario
A third-party contract used in LooksRare receives an update with a critical fix for a
vulnerability, but the update is not manually integrated in the LooksRare version of the
contract. An attacker detects the use of a vulnerable contract in the LooksRare protocol
and exploits the vulnerability against one of the contracts.

#### Recommendations
Short term, review the codebase and document the source and version of each
dependency. Include third-party sources as submodules in the project’s Git repository to
maintain internal path consistency and ensure that dependencies are updated periodically.

Long term, use an Ethereum development environment and NPM to manage packages in
the project.

Trail of Bits 31 LooksRare Security Assessment


-----

|