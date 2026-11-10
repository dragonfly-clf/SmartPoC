#### MSB - Max Supply Bypass


#### Description


The contract allows the owner to potentially exceed the predefined `MAX_SUPPLY` limit of

tokens through the `airdrop` function. preMintNFTsThis function lacks a check to ensure

that the total supply doesn't surpass `MAX_SUPPLY` when tokens are being minted during


the airdrop. The absence of such a check in the loop that performs the minting operation


can lead to scenarios where the total supply of tokens exceeds the intended limit.


#### Recommendation


It is recommended to introduce additional safeguards within the `airdrop` function to


prevent minting that exceeds the `MAX_SUPPLY` limit. This can be achieved by adding a


check before minting in the airdrop loop to ensure that the total minted quantity will not


surpass `MAX_SUPPLY .`


-----

