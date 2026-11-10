5. Redundant lookups in the Word RLC circuit|Col2|
|---|---|
|Severity: Informational|Difcfiulty: N/A|
|Type: Cryptography|Finding ID: TOB-SCROLL2-5|
|Target: src/gadgets/mpt_update/word_rlc.rs||


##### Description
The Word RLC circuit has two redundant lookups into the BytesLookup table.

The Word RLC circuit combines the random linear combination (RLC) for the lower and
upper 16 bytes of a word into a single RLC value. For this, it checks that the lower and
upper word segments are 16 bytes by looking into the BytesLookup table, and it checks
that their RLCs are correctly computed by looking into the RlcLookup table. However, the
lookup into the RlcLookup table will also ensure that the lower and upper segments of the
word have the correct 16 bytes, making the first two lookups redundant.
```
 pub fn configure<F: FieldExt>(
   cb: &mut ConstraintBuilder<F>,
   [word_hash, high, low]: [AdviceColumn; 3],
   [rlc_word, rlc_high, rlc_low]: [SecondPhaseAdviceColumn; 3],
   poseidon: &impl PoseidonLookup,
   bytes: &impl BytesLookup,
   rlc: &impl RlcLookup,
   randomness: Query<F>,
 ) {
   cb.add_lookup(
     "old_high is 16 bytes",
     [high.current(), Query::from(15)],
     bytes.lookup(),
   );
   cb.add_lookup(
     "old_low is 16 bytes",
     [low.current(), Query::from(15)],
     bytes.lookup(),
   );
   cb.poseidon_lookup(
     "word_hash = poseidon(high, low)",
     [high.current(), low.current(), word_hash.current()],
     poseidon,
   );
   cb.add_lookup(
     "rlc_high = rlc(high) and high is 16 bytes",
     [high.current(), Query::from(15), rlc_high.current()],

```
Trail of Bits 24 Scroll zkEVM Circuits Security Assessment


-----

_[Figure 5.1: mpt-circuit/src/gadgets/mpt_update/word_rlc.rs#16–49](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/src/gadgets/mpt_update/word_rlc.rs#L16-L49)_

Although the WordRLC::configure function receives two different lookup objects, bytes
and rlc, they are instantiated with the same concrete lookup:
```
 let mpt_update = MptUpdateConfig::configure(
   cs,
   &mut cb,
   poseidon,
   &key_bit,
   &byte_representation,
   &byte_representation,
   &rlc_randomness,
   &canonical_representation,
 );

```
_[Figure 5.2: mpt-circuit/src/mpt.rs#60–69](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/src/mpt.rs#L60-L69)_

We also note that the labels refer to the upper and lower bytes as old_high and old_low
instead of just high and low.

##### Recommendations
Short term, determine whether both the BytesLookup and RlcLookup tables are needed
for this circuit, and refactor the circuit accordingly, removing the redundant constraints.

Long term, review the codebase for duplicated or redundant constraints using manual and
automated methods.

Trail of Bits 25 Scroll zkEVM Circuits Security Assessment


-----

|