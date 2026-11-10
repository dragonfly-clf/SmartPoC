## QSP-22 Block Timestamp Manipulation

#### Severity: Informational

 Status: Acknowledged

###### File(s) affected: RariFundController.sol

 Description: Projects may rely on block timestamps for various purposes. However, it's important to realize that miners individually set the timestamp of a block, and attackers may be able to
 manipulate timestamps up to 900 seconds, for their own purposes. If a smart contract relies on a timestamp, it must take this into account.
 The checkLossRateLimit makes a decision based on the block timestamp on L537. However, the interval there seems to be 24 hours, which is a far larger than 900 seconds. Therefore, the
 attacker can only benefit by stopping the iteration of the for loop earlier than expected and use another value for lossRateLastDay than intended by the developer.


###### Recommendation: Use block.number instead of block.timestamp to avoid manipulation. Or clearly document that a 900 second error is possible and acceptable and would not have any
 impact on the actual logic, because the loss rates in the _lossRateHistory are not that different from each other.


###### Update:


###### From dev team: "We have added the suggested notice. We will note that in this case, it doesn't really matter in this case if the 1 day measurement is off by <= 900 seconds (15 min) as


###### the loss rate limit does not need to be this precise."

