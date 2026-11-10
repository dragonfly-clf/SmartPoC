L10. Unscalable Functionality: Missing Events Arguments
  The contract ByTradeToken defines the events Pause() and Unpause()
  with no arguments.
  Since the contract has an ownership transference functionality, it is
  recommended to track the address of the pausable functions’ calls.
  Path:
  ./contracts/ByTradeToken
  Recommendation: It is recommended to provide the msg.sender data in
  the Pause() and Unpause() events.
  Status: Reported
              www.hacken.io

```

-----

```
