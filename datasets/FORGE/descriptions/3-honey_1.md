#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** minor

**Location** contract.sol#L684

##### Description

The contract owner has the authority to transfer funds without limit to the team
wallet. These funds have been accumulated from fees collected from the contract.
The owner may take advantage of it by calling the rescueBNB method.

|Criticality|minor|
|---|---|
|Location|contract.sol#L684|


function rescueBNB(uint256 weiAmount) external onlyOwner{

require(address(this).balance >= weiAmount, "insufficient BNB balance");
payable(msg.sender).transfer(weiAmount);
}


##### Recommendation

The contract could embody a check for the maximum amount of funds that can be
swapped. Since a huge amount may volatile the token’s price.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|MAL|Misuse Algorithmic Logic|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L07|Missing Events Arithmetic|
|⬤|L13|Divide before Multiply Operation|


-----

