Incorrect Acces Control (3 item)

```
|Function|Severity|Remedation|
|---|---|---|
|Access control plays an important role in segregation of privileges in smart contracts and other applications. If this is misconfigured or not properly validated on sensitive functions, it may lead to loss of funds, tokens and in some cases compromise of the smart contract. The contract BABYTOKEN is importing an access control library @openzeppelin/contracts/ac cess/Ownable.sol but the function processDividendTracker is missing the modifier onlyOwner.|Severity : Critical|It is recommended to go through the contract and observe the functions that are lacking an access control modifier. If they contain sensitive administrative actions, it is advised to add a suitable modifier to the same|


-----

```
 