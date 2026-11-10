## QSP-38 Setter function missing event

#### Severity: Informational

 Status: Acknowledged

###### File(s) affected: RariFundManager.sol

```

###### to ensure that if users have staked LP tokens already, the LP token contract cannot be changed.


###### Description: Although the other setters are emitting events, the setter ‘setFundManagerData()’ has no corresponding event declared and is not emitting any event.

 Recommendation: Add an event to the function.

