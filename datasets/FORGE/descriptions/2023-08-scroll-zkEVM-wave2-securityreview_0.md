1. PoseidonLookup is not implemented|Col2|
|---|---|
|Severity: Informational|Difcfiulty: N/A|
|Type: Testing|Finding ID: TOB-SCROLL2-1|
|Target: src/gadgets/poseidon.rs||


-----

_[Figure 1.2: src/gadgets/poseidon.rs#56–80](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/src/gadgets/poseidon.rs#L56-L80)_

The rest of the codebase treats this trait as a black-box implementation, so this does not
seem to cause correctness problems elsewhere. However, it does limit one’s ability to test
some negative cases, and it makes the test coverage rely on the correctness of the
```
PoseidonTable struct’s witness generation.

##### Recommendations
```
Short term, create a concrete implementation of the PoseidonLookup trait to enable full
testing of the MPT circuit.

Long term, ensure that all parts of the MPT circuit are tested with both positive and
negative tests.

Trail of Bits 16 Scroll zkEVM Circuits Security Assessment


-----

|