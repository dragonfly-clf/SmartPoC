5. Excessive privileges of RoyaltyFeeSetter and RoyaltyFeeRegistry owners|Col2|
|---|---|
|Severity: Low|Difficulty: High|
|Type: Access Controls|Finding ID: TOB-LR-5|
|Target: contracts/royaltyFeeHelpers/RoyaltyFeeSetter.sol, contracts/royaltyFeeHelpers/RoyaltyFeeRegistry.sol||


#### Description
The RoyaltyFeeSetter and RoyaltyFeeRegistry contract owners can manipulate an
NFT collection’s royalty information, such as the fee percentage and the fee receiver; this
violates the principle of least privilege.

NFT collection owners can use the RoyaltyFeeSetter contract to set the royalty
information for their NFT collections. This information is stored in the
```
 RoyaltyFeeRegistry contract.

```
However, the owners of the two contracts can also update this information (figures 5.1 and
5.2).
```
 function updateRoyaltyInfoForCollection (
   address collection,
   address setter,
   address receiver,
   uint256 fee
 ) external override onlyOwner {
   require (fee <= royaltyFeeLimit, "Registry: Royalty fee too high" );
   _royaltyFeeInfoCollection[collection] = FeeInfo({
      setter: setter,
      receiver: receiver,
      fee: fee
   });
   emit RoyaltyFeeUpdate(collection, setter, receiver, fee);
 }

```
_Figure 5.1: The updateRoyaltyInfoForCollection function in_
```
               RoyaltyFeeRegistry :54-64

```
Trail of Bits 27 LooksRare Security Assessment


-----

This violates the principle of least privilege. Since it is the responsibility of the NFT
collection’s owner to set the royalty information, it is unnecessary for contract owners to
have the same ability.

#### Exploit Scenario
Alice, the owner of the RoyaltyFeeSetter contract, sets the incorrect receiver address
when updating the royalty information for Bob’s NFT collection. Bob is now unable to
receive fees from his NFT collection’s secondary sales.

#### Recommendations
Short term, remove the ability for users to update an NFT collection’s royalty information.

Long term, clearly document the responsibilities and levels of access provided to privileged
users of the system.

Trail of Bits 28 LooksRare Security Assessment


-----

|6. Insuącient protection of sensitive information|Col2|
|---|---|
|Severity: Low|Difficulty: High|
|Type: Configuration|Finding ID: TOB-LR-6|
|Target: contracts/hardhat.config.ts||


#### Description
Sensitive information, such as API keys, is stored in process environments. This method of
storage could make it easier for an attacker to compromise the information; compromise
of the Alchemy key, for example, could enable an attacker to use the key and use up all the
compute units, leading to a denial-of-service attack and the failure of other services reliant
on the node.

The following portion of the contracts/hardhat.config.ts file exposes an Alchemy
and Etherscan API key stored in the process environment:
```
 /**
  rinkeby: {
   url: `https://eth-rinkeby.alchemyapi.io/v2/${process.env.ALCHEMY_RINKEBY_PRIVATE_KEY}`,
   accounts: [process.env.RINKEBY_KEY],
  },
  */
  /**
   mainnet: {
    url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_MAINNET_PRIVATE_KEY}`,
    accounts: [process.env.MAINNET_KEY],
   },
   */

```
Trail of Bits 29 LooksRare Security Assessment


-----

_Figure 6.1: The Alchemy and Etherscan API keys from the process environment in the_
```
                hardhat.config.ts file

#### Exploit Scenario
```
Alice has the owner’s mainnet Alchemy key stored in her process environment. Eve, an
attacker, gains access to Alice’s device and extracts the key. Eve uses the Alchemy key,
using up all available compute units.

#### Recommendations
Short term, use a hardware security module to ensure that none of the keys can be
extracted.

Long term, take the following steps:

   - Move key material from the process environment to a dedicated secret

management system with trusted computing abilities. The best options for such a
system are the Google Cloud Key Management System and Hashicorp Vault (with
hardware security module backing).

   - Determine the business risk that would result from a lost or stolen key and develop

disaster recovery and business continuity policies to be implemented in such a case.

Trail of Bits 30 LooksRare Security Assessment


-----

|