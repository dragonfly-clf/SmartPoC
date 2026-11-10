1. Risk of reuse of signatures across forks due to lack of chainID validation|Col2|
|---|---|
|Severity: High|Difficulty: High|
|Type: Authentication|Finding ID: TOB-LR-1|
|Target: contracts/LooksRareExchange.sol||


-----

_Figure 1.1: contracts/contracts/LooksRareExchange.sol#L137-L145_

The _validateOrder function in the LooksRareExchange contract uses a
```
 SignatureChecker function, verify, to check the validity of a signature:
 // Verify the validity of the signature
 require (
   SignatureChecker.verify(
     orderHash,
     makerOrder.signer,
     makerOrder.v,
     makerOrder.r,
     makerOrder.s,
     DOMAIN_SEPARATOR
   ),
   "Signature: Invalid"
 );

```
_Figure 1.2: contracts/contracts/LooksRareExchange.sol#L576-L587_

However, the verify function checks only that a user has signed the domainSeparator .
As a result, in the event of a hard fork, an attacker could reuse signatures to receive user
funds on both chains. To mitigate this risk, if a change in the chainID is detected, the
domain separator can be cached and regenerated. Alternatively, instead of regenerating
the entire domain separator, the chainID can be included in the schema of the signature
passed to the order hash.
```
 /**
  * @notice Returns whether the signer matches the signed message
  * @param hash the hash containing the signed mesage
  * @param signer the signer address to confirm message validity
  * @param v parameter (27 or 28)
  * @param r parameter
  * @param s parameter
  * @param domainSeparator paramer to prevent signature being executed in other chains and
 environments
  * @return true --> if valid // false --> if invalid
  */
 function verify (
   bytes32 hash,
   address signer,
   uint8 v,
   bytes32 r,
   bytes32 s,
   bytes32 domainSeparator
 ) internal view returns ( bool ) {
   // \x19\x01 is the standardized encoding prefix

```
Trail of Bits 20 LooksRare Security Assessment


-----

_Figure 1.3: contracts/contracts/libraries/SignatureChecker.sol#L41-L68_

The signature schema does not account for the contract’s chain. If a fork of Ethereum is
made after the contract’s creation, every signature will be usable in both forks.

#### Exploit Scenario
Bob signs a maker order on the Ethereum mainnet. He signs the domain separator with a
signature to sell an NFT. Later, Ethereum is hard-forked and retains the same chain ID. As a
result, there are two parallel chains with the same chain ID, and Eve can use Bob’s
signature to match orders on the forked chain.

#### Recommendations
Short term, to prevent post-deployment forks from affecting signatures, add the chain ID
opcode to the signature schema.

Long term, identify and document the risks associated with having forks of multiple chains
and develop related mitigation strategies.

Trail of Bits 21 LooksRare Security Assessment


-----

|