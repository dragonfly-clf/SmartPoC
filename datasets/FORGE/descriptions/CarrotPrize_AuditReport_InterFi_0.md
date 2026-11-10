MANUAL REVIEW

Identifier Definition

CEN-01 Centralization privileges of Carrot Prize

Centralized privileges are listed below:

|Identifier|Definition|Severity|
|---|---|---|
|CEN-01|Centralization privileges of Carrot Prize|Major "|


"

```
transferOwnership()

```
```
editUsdtRank()

```
```
editTeamAddress()

```
```
rescueToken()

```
```
rescueEth()

```

**RECOMMENDATION**

Deployer and/or contract owner private keys are secured carefully. Please refer to PAGE-09

CENTRALIZED PRIVILEGES for a detailed understanding.


-----

|Identifier|Definition|Severity|
|---|---|---|
|LOG-01|Lack of arbitrary limits|Minor $|


$


Below mentioned function is set without any arbitrary limits.

```
editUSDTRank()

```

**RECOMMENDATION**

This function should be provided arbitrary limit, e.g., put a require check that validates input.


-----

LOG-04 Missing important checks Medium #

Below mentioned external functions should be checked for adequate access control:
```
participateGameRank1()
participateGameRank2()
participateGameRank3()
participateGameRank4()
participateGameRank5()

```
|Identifier|Definition|Severity|
|---|---|---|
|LOG-04|Missing important checks|Medium #|


#


**RECOMMENDATION**


To specify access control and deter potential exploit, fix input and msg.sender requirements.


-----

|Identifier|Definition|Severity|
|---|---|---|
|COD-02|Timestamp manipulation via block.timestamp Avoid using block.number as timestamp|Minor $|


$


Be aware that the timestamp of the block can be manipulated by a miner. When the contract uses

the timestamp to seed a random number, the miner can actually post a timestamp within 15 seconds

of the block being validated, effectively allowing the miner to precompute an option more favorable

to their chances, this is a critical exploit for contracts calculating random numbers, e.g., lottery.

**RECOMMENDATION**

To maintain block integrity, follow 15 seconds rule, and scale time dependent events accordingly.


-----

|Identifier|Definition|Severity|
|---|---|---|
|COD-05|Missing zero address validation||


Below mentioned function’s input must be validated:

```
editTeamAddress()

```

**RECOMMENDATION**

Validate if the modified address is dead(0) or not.


-----

|Identifier|Definition|Severity|
|---|---|---|
|COD-06|Unknown externally owned account|Minor $|


$


An externally owned account (EOA) has no code, and one can send messages from an externally

owned account by creating and signing a transaction.

```
  address public teamAddress = address(0xb09ecE278e324ff889624B03A53D4D201c56bf2e);

```

**RECOMMENDATION**

Private keys of externally owned accounts must be secured carefully.


-----

|Identifier|Definition|Severity|
|---|---|---|
|COD-10|Third Party Dependencies|Minor $|


$


Smart contract is interacting with third party protocols e.g., Pancakeswap, Uniswap. The scope of the

audit treats third party entities as black boxes and assumes their functional correctness. However, in

the real world, third parties can be compromised, and exploited. Moreover, upgrades in third parties

can create severe impacts, e.g., increased transactional fees, deprecation of previous routers, etc.

**RECOMMENDATION**

Inspect third party dependencies regularly, and mitigate severe impacts whenever necessary.


-----

