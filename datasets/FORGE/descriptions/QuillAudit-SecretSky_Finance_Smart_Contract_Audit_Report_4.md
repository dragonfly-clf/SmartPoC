###### Reentrancy Issue 4.

 [#L327-340]As mentioned in the Mythril report in the Automated Tools section. External call to spender address can result in the reentrancy. If the spender is a contract, it can issue a reentrant call to any of this contract’s function from its fallback function.

 5. [#L342]Unused Event LogInt()

 6.approve() race
 The standard ERC20 implementation contains a widely-known racing condition in its approve function, wherein a spender is able to witness the token owner broadcast a transaction altering their approval and quickly sign and broadcast a transaction using transferFrom to move the current approved amount from the owner’s balance to the spender. If the spender’s transaction is validated before the owner’s, the spender is able to spend their entire approval amount twice.

 Reference:

 https://docs.google.com/document/ d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit
 https://medium.com/mycrypto/bad-actors-abusing-erc20-approval- to-steal-your-tokens-c0407b7f7c7c
 https://eips.ethereum.org/EIPS/eip-20

