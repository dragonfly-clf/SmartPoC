20. Template code
  To save Gas costly reassignment operations should not be used.
  Changing and reverting values for special calls is not a good way to
  solve this problem. It is better to process special arguments to the
  final destination where the changes are needed.
  Contract: FidoMeta.sol
  Function: _tokenTransfer
  Recommendation: get rid of template code and previous value
  variables, structure actions sequentially, and process all options on
  the corresponding level of abstractions.
  Status: Acknowledged
