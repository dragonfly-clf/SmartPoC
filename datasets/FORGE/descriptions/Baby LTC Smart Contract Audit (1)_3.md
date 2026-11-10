Unchecked Transfers (3 Item)

```
|Function|Severity|Remedation|
|---|---|---|
|Some tokens do not revert the transaction when the transfer or transferFrom fails and returns False. Hence we must check the return value after calling the transfer or transferFrom function.|Severity : High|Use OpenZeppelin SafeERC20's safetransfer and safetransferFrom functions.|


-----

```
