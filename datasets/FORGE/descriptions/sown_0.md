#### MT - Mints Tokens


#### Description


The contract `Bnt` role has the authority to mint tokens. The `Bnt` role may take


advantage of it by calling the `sownFromBnt` function. As a result, the contract tokens


will be highly inflated.


#### Recommendation


The team should carefully manage the private keys of the `Bnt` role account. It is crucial

that the Bnt role exercises utmost caution when interacting with the contract.


#### Team Update


The ownership has been transferred to the


`0x3d08b97608b73fa423d52489fd18a5c67d775270` contract and cannot be


changed. The team states that it’s a dual token protocol, the circulatory supply of Bnt


controls the circulatory supply of SOWN. Nobody can mint or burn not even the contract


owner. People can convert their Bnt to SOWN or SOWN to Bnt.


-----

