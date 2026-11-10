L05. Missing Error Message
  In ByTradeToken, the modifier whenNotPaused() does not provide an
  error message in the require() check.
  Error messages are intended to notify users about failing conditions,
  and should provide enough information so that the appropriate
  corrections needed to interact with the system can be applied.
  Uninformative error messages greatly damage the overall user
  experience, thus lowering the system’s quality.
  If the mentioned require statement fails the checked condition, the
  transaction will revert silently without an informative error
  message.
  Path:
  ./contracts/ByTradeToken: whenNotPaused()
  Recommendation: It is recommended to add an appropriate error message
  in the modifier whenNotPaused().
  Status: Reported
