21. Overwhelmed code
  Unneeded reassignment is provided. take variables could be defined
  already with actual values. Moreover, as they are unused there
  directly, it is better to use them in _getTValues function where
  their sense is needed.
  Contract: FidoMeta.sol
  Function: _transfer
  Recommendation: update the code and use values exactly where they are
  needed.
  Status: Acknowledged
