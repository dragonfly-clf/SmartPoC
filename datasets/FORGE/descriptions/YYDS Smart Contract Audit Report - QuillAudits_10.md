A.8: Missing event emission

 Description

 Some of the contract functions that update the token’s state do not emit events when called. It is advisable for ease of tracking changes on the blockchain to emit events. The following functions could have events emitted when called: setBuyInterval, setMaxTokenVaulePerTx, setMaxTokenVauleSellPerTx, setIntervalDays, setBuyMarketingFee, setSellMarketingFee, setNumTokensSellToSwap, setMinAmountDeflation, and setMinAmountBurn.

 Recommendation(s)

 Emit events for these changes to the token’s state for ease of tracking and logging.

 Status

 Acknowledged

### 