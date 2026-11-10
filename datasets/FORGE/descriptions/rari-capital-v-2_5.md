## QSP-6 Unchecked Return Value

#### Severity: Medium Risk

 Status: Fixed

###### File(s) affected: CompoundPoolController.sol


###### Description: Most functions will return a value indicating success or failure. It's important to ensure that every necessary function is checked. Otherwise, the caller just assumes that the function call was successful and continues execution. This is the case for the function call cErc20.accrueInterest() on L49 in CompoundPoolController.sol, whose return value is not checked.

 Recommendation: Wrap the statement in a check like so: require(cErc20.accrueInterest() == uint(Error.NO_ERROR), "accrue interest failed");

