#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** minor

**Location** contract.sol#L928

##### Description

The contract owner has the authority to transfer funds without limit to the team
wallet. These funds have been accumulated from fees collected from the contract.
The owner may take advantage of it by calling the withdrawAllToTreasury method.

|Criticality|minor|
|---|---|
|Location|contract.sol#L928|


function withdrawAllToTreasury() external swapping onlyOwner {

uint256 amountToSwap = _gonBalances[address(this)].div(

_gonsPerFragment
);
require(

amountToSwap > 0,
"There is no TED token deposited in token contract"
);
address[] memory path = new address[](2);
path[0] = address(this);
path[1] = router.WETH();
router.swapExactTokensForETH(

amountToSwap,
0,
path,
treasuryReceiver,
block.timestamp
);
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
|⬤|MTS|Manipulate Total Supply|
|⬤|L01|Public Function could be Declared External|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L05|Unused State Variable|
|⬤|L07|Missing Events Arithmetic|
|⬤|L09|Dead Code Elimination|
|⬤|L13|Divide before Multiply Operation|


-----

