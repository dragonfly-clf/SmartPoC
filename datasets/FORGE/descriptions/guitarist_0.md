#### PRE - Potential Reentrance Exploit


#### Description


The contract makes an external call to transfer funds to recipients using the payable transfer


method. The recipient could be a malicious contract that has an untrusted code in its


fallback function that makes a recursive call back to the original contract. The re-entrance


exploit could be used by a malicious user to drain the contract’s funds or to perform


unauthorized actions. This could happen because the original contract does not update the


state before sending funds.


Specifically, when the `_safeMint` function, is called within the `mint` function, it


executes the `_checkOnERC721Received` function. The


`_checkOnERC721Received` function is designed to verify if the recipient address (in this


case, the sender of the mint transaction) is a contract that properly implements the


IERC721Receiver interface. However, if this recipient is a malicious contract, it could


override the onERC721Received function to initiate a new call to the contract's mint


function.


Given the current implementation, this recursive call could potentially bypass the


`MAX_SUPPLY` check, as the state variable representing the total supply of minted NFTs (

```
totalSupply ) is updated only after the external call. As a result, since the reentrant call

```

occurs before the `_currentIndex` variable is increased (which reflects the


`totalSupply` value), it could allow minting more NFTs than the intended maximum


supply, violating the contract's supply constraints and potentially leading to other


unintended consequences.


-----

#### Recommendation


-----

The team is advised to prevent the potential re-entrance exploit as part of the solidity best


practices. Some suggestions are:



- Add lockers/mutexes in the method scope. It is important to note that mutexes do

not prevent cross-function reentrancy attacks.

- Do Not allow contract addresses to receive funds.

- Proceed with the external call as the last statement of the method, so that the state

will have been updated properly during the re-entrance phase.


-----

