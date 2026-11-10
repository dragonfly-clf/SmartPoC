L11. Redundant Initialization of Default Values
  The constructor() in ByTradeToken initializes the state variable
  paused = false. Uninitialized bools are set as false, so it is
  redundant to set said variable to false.
  Accessing storage variables is expensive in terms of Gas, and should
  therefore be minimized.
  Path:
  ./contracts/ByTradeToken: constructor().
  Recommendation: Avoid unnecessary variable initializations.
  Status: Reported
