#### Medium severity issues

1. Account addresses should not be non-updateable as this could address recovery
problems. If the private key is lost for any of the addresses, the address stored in the
contract cannot be updated to a new address. This could cause funds to eventually go to
addresses without a private key which means it will be lost forever.

We recommend all account addresses to be updateable by the owner or some other
recovery strategy should be kept in mind to make sure funds never go to a lost address.

**Amended (March 23th 2021): Issue was fixed by HaggleX team and is no longer**
present in the contract shared.

