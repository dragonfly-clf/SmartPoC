#### Missing Zero Address Validation (1 Detected Item)

##### Some functions in this contract may not appropriately check for zero addresses being used.

|Function|Severity|Relevant Snippet|
|---|---|---|
|Issue Location in Code StandardToken.constructor(string,s tring,uint8,uint256,address,uint25 6).serviceFeeReceiver_ (StandardToken.sol#467) lacks a zero-check on : - address(serviceFeeReceiver_).trans fer(serviceFee_) (StandardToken.sol#477)|Severity: Moderat e|address serviceFeeReceiver_,|


-----

