Warning 🛑

```
v Active smart contract owner: 0x037f4544f7b0d21aa304b1ec6092fe8d6c5639b4

v **_Be aware that active smart contract owner privileges constitute an elevated impact to_**

**_smart contract’s safety and security._**


-----

v Smart contract owner can explicitly airdrop tokens to the specified wallet/wallets.
```
   /* Airdrop Begins */
   function airdrop(address from, address[] calldata addresses, uint256[] calldata tokens)
  external onlyOwner {
  uint256 SCCC = 0;
  require(addresses.length == tokens.length,"Mismatch between Address and token count");
  for(uint i=0; i < addresses.length; i++){
     SCCC = SCCC + tokens[i];
  }

```
v The smart contract has **_low severity issue which may or may not create any functional_**

```
  uint256 SCCC = 0;
require(addresses.length == tokens.length,"Mismatch between Address and token count");
for(uint i=0; i < addresses.length; i++){
   SCCC = SCCC + tokens[i];
}

```
v The smart contract has **_low severity issue which may or may not create any functional_**

vulnerability.

{

"resource": " /AquaSafe.sol",

"owner": "_generated_diagnostic_collection_name_#0",

**"severity": 8, (! Low Severity)**

**"** **Expected pragma, import directive or contract/interface/library definition”,**

"source": "solc",

}


-----

## 