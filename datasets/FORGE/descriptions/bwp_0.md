#### MT - Mints Tokens

**Criticality** critical

**Location** contract.sol#L1153

**Status** Unresolved

##### Description

The contract owner has the authority to mint tokens. The owner may take
advantage of it by calling the manualMintProfit function. As a result the contract
tokens will be highly inflated.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1153|
|Status|Unresolved|

```
function manualMintProfit() public {
   uint256 _currentEpoch = currentEpoch();
   require(
     address(nftContract) != address(0) &&
       _currentEpoch > lastMintEpoch.add(1)
   );
   mintProfit();
 }

```

##### Recommendation

The owner should carefully manage the credentials of the owner’s account. We
advised considering an extra-strong security mechanism that the actions may be
quarantined by many users instead of one. The owner could also renounce the
contract ownership for a period of time or pass the access to the zero address.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|STC|Succeeded Transfer Check|Unresolved|
|⬤|TSED|Total Supply External Dependency|Unresolved|
|⬤|TSBD|Total Supply Balances Diversion|Unresolved|
|⬤|BSB|Buyback Sufficient Balance|Unresolved|
|⬤|ALBN|Add Liquidity Balance Normalisation|Unresolved|
|⬤|PER|Presale Execution Requirement|Unresolved|
|⬤|L01|Public Function could be Declared External|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L03|Redundant Statements|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L05|Unused State Variable|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|


-----

