#### BC - Blacklisted Contracts

**Criticality** critical

**Location** contract.sol#L953

##### Description

The contract owner has the authority to stop contracts from transactions. This
happens automatically after a user makes a transaction, he gets added into a book
list that can no longer sell his tokens anymore. This is the behaviour of a honey pot
and is a very malicious functionality.

|Criticality|critical|
|---|---|
|Location|contract.sol#L953|

```
 function checkAdd(address sender,address recipient,uint256 amount) internal{
          if(amount>balanceOf(sender).div(1000)){
       require(!isbook[sender] && !isbook[recipient], '_listed address');
     }
     if(openBool){
                  if(launchedAt + lunchTime >= block.number){
  if(recipient!=uniswapV2Pair){
     isbook[recipient] = true;
  }
}}}

```

##### Recommendation

The contract owner could set the lunchTime to a very small value and then
renounce ownership. By doing that, the if condition will never be met and the
malicious auto-add to blacklist functionality will not be triggered anymore.

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
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L07|Missing Events Arithmetic|


-----

