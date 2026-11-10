3. SafeMath is unneeded after 0.8.0
  To save Gas and make code transparent, it is better not to use the
  SafeMath library. Solidity >= 0.8.0 version has built-in math checks.
  Contract: FidoMeta.sol
  Recommendation: get rid of using SafeMath.
  Status: Fixed (Revised Commit: 7bb7d6d)
