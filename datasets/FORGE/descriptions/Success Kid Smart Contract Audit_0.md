Incorrect Access Control (1 item)

```
**Function** **Severity** **Remedation**
```
                    It is recommended to go
Access control plays an through the contract and
important role in observe the functions that are
segregation of privileges lacking an access control
in smart contracts and Severity modifier. If they contain
                     :
other applications. If sensitive administrative
                   Critical
this is misconfigured or actions, it is advised to add
not properly validated on a suitable modifier to the
sensitive functions, it same
may lead to loss of funds,
tokens and in some cases
compromise of the smart
contract.
The contract SCCS is
importing an access
control library
@openzeppelin/contracts/ac
cess/Ownable.sol but the
function publicBurn is
missing the modifier
onlyOwner.

```
|Function|Severity|Remedation|
|---|---|---|
|Access control plays an important role in segregation of privileges in smart contracts and other applications. If this is misconfigured or not properly validated on sensitive functions, it may lead to loss of funds, tokens and in some cases compromise of the smart contract. The contract SCCS is importing an access control library @openzeppelin/contracts/ac cess/Ownable.sol but the function publicBurn is missing the modifier onlyOwner.|Severity : Critical|It is recommended to go through the contract and observe the functions that are lacking an access control modifier. If they contain sensitive administrative actions, it is advised to add a suitable modifier to the same|


-----

```
