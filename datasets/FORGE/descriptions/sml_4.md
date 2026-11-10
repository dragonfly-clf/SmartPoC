#### RV - Randomization Vulnerability

**Criticality** minor / informative

**Location** contract.sol#L1285

**Status** Unresolved

##### Description

The contract is using an on chain technique in order to determine random numbers.
The blockchain runtime environment is fully deterministic, as a result, the
pseudo-random numbers could be predicted.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1285|
|Status|Unresolved|

```
function draw(uint _modulus) public {
...
}

```

##### Recommendation

The contract could use an advanced randomization technique that guarantees an
acceptable randomization factor. For instance, the Chainlink VRF (Verifiable Random
Function). [https://docs.chain.link/docs/chainlink-vrf/](https://docs.chain.link/docs/chainlink-vrf/)


-----

