11. isContract may behave unexpectedly|Col2|
|---|---|
|Severity: Informational|Difficulty: Undetermined|
|Type: Undefined Behavior|Finding ID: TOB-LR-11|
|Target: contracts/libraries/SignatureChecker.sol||


#### Description
The LooksRare exchange relies on OpenZeppelin’s SignatureChecker library to verify
signatures on-chain. This library, in turn, relies on the isContract function in the Address
library to determine whether the signer is a contract or an externally owned account (EOA).
However, in Solidity, there is no reliable way to definitively determine whether a given
address is a contract, as there are several edge cases in which the underlying
```
 extcodesize function can return unexpected results.
 function isContract( address account) internal view returns ( bool ) {
   // This method relies on extcodesize, which returns 0 for contracts in
   // construction, since the code is only stored at the end of the
   // constructor execution.
   uint256 size;
   assembly {
    size := extcodesize (account)
   }
   return size > 0;
 }

```
_Figure 11.1: The isContract function in Address.sol #L27-37_

#### Exploit Scenario
A maker order is created and signed by a smart contract wallet. While this order is waiting
to be filled, selfdestruct is called on the contract. The call to extcodesize returns 0,
causing isContract to return false. Even though the order was signed by an
ERC1271-compatible contract, the verify method will attempt to validate the signer’s
address as though it were signed by an EOA.

#### Recommendations
Short term, clearly document for developers that SignatureChecker.verify is not
guaranteed to accurately distinguish between an EOA and a contract signer, and
emphasize that it should never be used in a manner that requires such a guarantee.

Long term, avoid adding or altering functionality that would rely on a guarantee that a
signature’s source remains consistent over time.

Trail of Bits 36 LooksRare Security Assessment


-----

|