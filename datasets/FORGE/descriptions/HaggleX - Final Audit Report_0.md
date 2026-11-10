#### High severity issues

1. In function staking, line number 1076 gives control to the user to set the array length of
variable _staking[_msgSender()][]. This is critical because the function unstake loops
over this array length to delete an index from _staking. In case the array length is large
enough, the function unstake can easily run out of gas and there is no way the array
length can be decreased in any way externally.

We recommend that it is ensured that there is some limit on the length of the array so
that unstake can never run out of gas. Another alternative could be to not implement the
**_removeIndexInArray function to delete the index and make sure that the functions in**
the contract using the _staking variable are aware that an index is deleted. One way this
can be done is by maintaining a mapping in place of the array, maintaining a latest stake
index mapping for all addresses and adding another variable to the Stake struct to
maintain the unstake or deleted status. There can be other ways to handle this as well.

**Amended (March 23th 2021): Issue was fixed by HaggleX team and is no longer**
present in the contract shared.

This audit does not provide a security or correctness guarantee of the audited smart contract. Securing smart contracts is a
multistep process, therefore running a bug bounty program as a complement to this audit is strongly recommended.


-----

