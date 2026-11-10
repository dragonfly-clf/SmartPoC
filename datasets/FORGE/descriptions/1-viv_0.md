#### The total supply is half of the total balances

The contract’s total supply is 1,000,000,000 VIV.
During the deployment, 1,000,000,000 VIV were minted to the owner’s address
**0x9a66a737ed8d1bae7789598a0db03b4da9d48a72 and 1,000,000,000 VIV were**
added to the 0x9Ab605d4A60dF5727402b03F73367FEdf760693D address.
That means that the total supply of the contract is half of the balance’s sum.


-----

### Contract Analysis

|Col1|⬤|Critical|⬤|Medium|⬤|Minor|⬤|Pass|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|ST|Contract Owner is not able to stop or pause transactions|
|⬤|OCTD|Contract Owner is not able to transfer tokens from specific address|
|⬤|OTUT|Owner Transfer User's Tokens|
|⬤|ELFM|Contract Owner is not able to increase fees more than a reasonable percent (25%)|
|⬤|ULTW|Contract Owner is not able to increase the amount of liquidity taken by dev wallet more than a reasonable percent|
|⬤|MT|Contract Owner is not able to mint new tokens|
|⬤|BT|Contract Owner is not able to burn tokens from specific wallet|
|⬤|BC|Contract Owner is not able to blacklist wallets from selling|


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|


-----

