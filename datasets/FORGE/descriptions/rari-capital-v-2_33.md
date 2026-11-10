## QSP-34 Faulty dev environment might not print some enum and struct layout errors

#### Severity: Low Risk

 Status: Fixed

###### File(s) affected: rari-yield-pool-contracts/package.json

 Description: As described in this forum update, truffle-upgrades supports the unsafeAllowCustomTypes flag. Due to an implementation error of this flag, older versions might not display some storage layout errors for enum and struct.

 Recommendation: Upgrade to the latest version of truffle-upgrades, at least 1.3.1.

