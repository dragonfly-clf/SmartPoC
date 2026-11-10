22. Solidity Private Modifier Do Not Hide Data

 Description ITo favor explicitness, consider everything that is inside a contract is visible to all observers external to the blockchain. Therefore, the Auditee should be aware that making something private only prevents other contracts from reading or modifying the information, but it will still be visible to the whole world outside of the blockchain.

 0519


-----

###### For example, the following private variables in GARFIELD contract are still visible and accessible:   uint256 private constant MAX = ~uint256(0);   uint256 private _tTotal = 1000000000000 * 10 ** 9;   uint256 private _rTotal = (MAX - (MAX % _tTotal));   uint256 private _tFeeTotal

 Status: Acknowledged by the Auditee

 