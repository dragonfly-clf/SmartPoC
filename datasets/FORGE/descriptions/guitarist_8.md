#### RPF - Redundant Payable Function

**Criticality** Minor / Informative

**Location** Guitarist.sol#L1585,1612

**Status** Unresolved

#### Description

The contract's function `airdrop` and `partnerMint` have the `payable` modifier

which means that the contract owner pays with the native token. The function does not use

the `msg.value` variable anywhere inside the function to indicate the usage of the

payable modifier. As a result, the payable modifier is redundant.
```
   function airdrop(address[] calldata receiver, uint256[] calldata
 quantity) public payable onlyOwner {
      require(receiver.length == quantity.length, "Airdrop data
 does not match");
      for(uint256 x = 0; x < receiver.length; x++){
      _safeMint(receiver[x], quantity[x]);
      }
   }
   function partnerMint(address partner, uint256 quantity) public
 payable onlyOwner {
      require(totalSupply() + quantity <= MAX_SUPPLY,"No More NFTs
 to Mint");
      _safeMint(partner, quantity);
   }

#### Recommendation

```
The team is advised to remove the payable modifier from the function's declaration as it is

not needed.


-----

