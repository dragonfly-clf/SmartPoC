#### RV - Randomization Vulnerability

**Criticality** minor

**Location** contract.sol#L887

##### Description

The contract is using an on chain technique in order to determine random numbers.
The blockchain runtime environment is fully deterministic, as a result, the
pseudo-random numbers could be predicted.

|Criticality|minor|
|---|---|
|Location|contract.sol#L887|

```
function random(uint256 number) public view returns(uint256){
    return
uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty,
msg.sender))) % number;
}

```

##### Recommendation

The contract could use an advanced randomization technique that quarandees an
acceptable randomization factor. For instance, the Chainlink VRF (Verifiable Random
Function).

[https://docs.chain.link/docs/chainlink-vrf/](https://docs.chain.link/docs/chainlink-vrf/)


-----

