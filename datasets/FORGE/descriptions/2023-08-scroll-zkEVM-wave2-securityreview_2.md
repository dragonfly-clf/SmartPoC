3. The MPT nonexistence proof gadget is missing constraints specified in the documentation|Col2|
|---|---|
|Severity: Informational|Difcfiulty: N/A|
|Type: Cryptography|Finding ID: TOB-SCROLL2-3|
|Target: src/gadgets/mpt_update/nonexistence_proof.rs||


##### Description
The gadget for checking the consistency of nonexistence proofs is missing several
constraints related to type 2 nonexistence proofs.

The circuit specification includes constraints for the nonexistence of path proofs that are
not included in the implementation. This causes the witness values to be unconstrained in
[some cases. For example, the following constraints are specified:](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/spec/mpt-proof.md?plain=1#L167-L174)

  - `other_key_hash should equal 0 when key does not equal other_key.`

  - `other_leaf_data_hash should equal the hash of the empty node (pointer by`
```
   other_key).

```
Neither of these constraints is enforced in the implementation: this is because the
implementation has no explicit constraints imposed for the type 2 nonexistence proofs.
Figure 3.1 shows that the circuit constrains these values only for type 1 proofs.
```
 pub fn configure<F: FieldExt>(
   cb: &mut ConstraintBuilder<F>,
   value: SecondPhaseAdviceColumn,
   key: AdviceColumn,
   other_key: AdviceColumn,
   key_equals_other_key: IsZeroGadget,
   hash: AdviceColumn,
   hash_is_zero: IsZeroGadget,
   other_key_hash: AdviceColumn,
   other_leaf_data_hash: AdviceColumn,
   poseidon: &impl PoseidonLookup,
 ) {
   cb.assert_zero("value is 0 for empty node", value.current());
   cb.assert_equal(
     "key_minus_other_key = key - other key",
     key_equals_other_key.value.current(),
     key.current() - other_key.current(),
   );
   cb.assert_equal(

```
Trail of Bits 19 Scroll zkEVM Circuits Security Assessment


-----

_[Figure 3.1: mpt-circuit/src/gadgets/mpt_update/nonexistence_proof.rs#7–54](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/src/gadgets/mpt_update/nonexistence_proof.rs#L7-L54)_

The Scroll team has stated that this is a specification error and that the missing constraints
do not impact the soundness of the circuit.

##### Recommendations
Short term, update the specification to remove the description of these constraints; ensure
that the documentation is kept updated.

Long term, add positive and negative tests for both types of nonexistence proofs.

Trail of Bits 20 Scroll zkEVM Circuits Security Assessment


-----

|