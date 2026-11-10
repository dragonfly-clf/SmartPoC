##### OTUT - Owner Transfer User’s Tokens

**Criticality** high

**Location** https://www.bscscan.com/address/0x4D5f45C030627c9CA6D555119A0a1Ed290A
B1140#code#L166

###### Description

The contract owner has the authority to transfer the balance of a user’s contract to
the owner’s contract. The owner may take advantage of it by calling the
```
transferAnyERC20Token function.

```
|Criticality|high|
|---|---|
|Location|https://www.bscscan.com/address/0x4D5f45C030627c9CA6D555119A0a1Ed290A B1140#code#L166|

```
function transferAnyERC20Token(address _tokenAddress, uint _tokens) external
onlyOwner returns (bool success) {
  return IERC20(_tokenAddress).transfer(owner, _tokens);
}

```

###### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

#### Contract Diagnostics

|Pass|Name|
|---|---|
|✓|Integer Underflow|
|✓|Parity Multisig Bug|
|✓|Callstack Depth Attack|
|✓|Transaction-Ordering Dependency|
|✓|Timestamp Dependency|
|✓|Re-Entrancy|


-----

#### Contract Functions

|Contract|Type|Bases|Col4|Col5|
|---|---|---|---|---|
||Function Name|Visibility|Mutability|Modifiers|
||||||
|SafeMath|Library||||
||add|Internal|||
||sub|Internal|||
||mul|Internal|||
||div|Internal|||
||||||
|IERC20|Interface||||
||transfer|External ️|✓|-️|
||transferFrom|External ️|✓|-️|
||balanceOf|External ️||-️|
||approve|External ️|✓|-️|
||allowance|External ️||-️|
||totalSupply|External ️||-️|
||||||


-----

|Ownable|Implementation|Col3|Col4|Col5|
|---|---|---|---|---|
|||Public️|✓|-️|
||transferOwnership|Public️|✓|onlyOwner|
||||||
|Pausable|Implementation|Ownable|||
|||Internal|✓||
||paused|Public️||-️|
||pause|External ️|✓|onlyOwner|
||unpause|External ️|✓|onlyOwner|
||||||
|BudzToken|Implementation|IERC20, Pausable|||
|||Public️|✓|-️|
||transfer|External ️|✓|-️|
||transferFrom|External ️|✓|-️|
||approve|External ️|✓|canApprove|
||allowance|External ️||-️|
||balanceOf|External ️||-️|
||totalSupply|External ️||-️|
||burn|External ️|✓|onlyOwner|


-----

|Col1|transferAnyERC20Token|External ️|✓|onlyOwner|
|---|---|---|---|---|


-----

#### Contract Flow


-----

#### Domain Info

**Domain Name** metabudz.net

**Registry Domain ID** 2659150363_DOMAIN_NET-VRSN

**Registrar WHOIS** whois.namecheap.com
**Server**

**Registrar URL** http://www.namecheap.com

**Updated Date** 0001-01-01T00:00:00.00Z (wrong information)

**Creation Date** 2021-12-03T00:54:43.00Z

**Registry Expiry Date** 2022-12-03T00:54:43.00Z

**Registrar** NAMECHEAP INC

**Registrar IANA ID** 1068

The domain has been created one week before the creation of the audit. It will
expire in one year.

There is no public billing information, the creator is protected by the privacy
settings.

|Domain Name|metabudz.net|
|---|---|
|Registry Domain ID|2659150363_DOMAIN_NET-VRSN|
|Registrar WHOIS Server|whois.namecheap.com|
|Registrar URL|http://www.namecheap.com|
|Updated Date|0001-01-01T00:00:00.00Z (wrong information)|
|Creation Date|2021-12-03T00:54:43.00Z|
|Registry Expiry Date|2022-12-03T00:54:43.00Z|
|Registrar|NAMECHEAP INC|
|Registrar IANA ID|1068|


-----

#### Stacking Contract

BudzToken ecosystem contains a contract that is dedicated to stacking. Users have
the ability to stack tokens for a period of time and get more tokens as a reward. The
Stacking contract incarnates the standard stacking functionality.

#### Stacking Contract Review

|Contract Name|BudzStake|
|---|---|
|Compiler Version|v0.6.12+commit.27d51765|
|Optimization|200 runs|
|Licence|NONE|
|Explorer|https://www.bscscan.com/address/0x41B2BA88a0DE898 86277d2e8C083884B6dF2ea47|


-----

#### Stacking Contract Functions

|Contract|Type|Bases|Col4|Col5|
|---|---|---|---|---|
||Function Name|Visibility|Mutability|Modifiers|
||||||
|IERC20|Interface||||
||transfer|External ️|✓|-️|
||transferFrom|External ️|✓|-️|
||balanceOf|External ️||-️|
||approve|External ️|✓|-️|
||allowance|External ️||-️|
||totalSupply|External ️||-️|
||||||
|SafeMath|Library||||
||add|Internal|||
||sub|Internal|||
||mul|Internal|||
||div|Internal|||
||mod|Internal|||
||mod|Internal|||
||||||
|Owned|Implementation||||
|||Public️|✓|-️|
||transferOwnership|Public️|✓|onlyOwner|
||||||
|BudzStake|Implementation|Owned|||
|||Public️|✓|-️|
||registerAndStake|External ️|✓|onlyUnregis tered whenActive|


-----

|Col1|calculateEarnings|Public️|Col4|-️|
|---|---|---|---|---|
||stake|External ️|✓|onlyRegiste red whenActive|
||unstake|External ️|✓|onlyRegiste red|
||withdrawEarnings|External ️|✓|-️|
||rewardPool|External ️||onlyOwner|
||changeActiveStatus|External ️|✓|onlyOwner|
||setStakingTaxRate|External ️|✓|onlyOwner|
||setUnstakingTaxRate|External ️|✓|onlyOwner|
||setDailyROI|External ️|✓|onlyOwner|
||setRegistrationTax|External ️|✓|onlyOwner|
||setMinimumStakeValue|External ️|✓|onlyOwner|
||filter|External ️|✓|onlyOwner|


-----

#### Stacking Contract Flow


-----

