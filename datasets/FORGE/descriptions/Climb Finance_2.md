##### 1. No delegates move

Issue:

There is no call of _moveDelegates in function mint in the MNTNToken
contract at line 741.

Recommendation:

Please add _moveDelegates from zero address to minted address after
[minting as it developed in GooseDefi contracts](https://github.com/goosedefi/goose-contracts/blob/ac22b7087df9d46bd95771a4f669b03e35386b59/contracts/EggToken.sol#L8) from where the
MNTNToken copied.

Also there should be a call of _moveDelegates function from burnable
address to zero address in the burn function in the MNTNToken contract.

