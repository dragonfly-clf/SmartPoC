9. The OneHot primitive allows more than one value at once|Col2|
|---|---|
|Severity: High|Difcfiulty: Low|
|Type: Cryptography|Finding ID: TOB-SCROLL2-9|
|Target: constraint_builder/binary_column.rs||


##### Description
The OneHot primitive uses BinaryQuery values as witness values. However, despite their
name, these values are not constrained to be Boolean values, allowing a malicious prover
to choose more than one “hot” value in the data structure.
```
 impl<T: IntoEnumIterator + Hash + Eq> OneHot<T> {
   pub fn configure<F: FieldExt>(
     cs: &mut ConstraintSystem<F>,
     cb: &mut ConstraintBuilder<F>,
   ) -> Self {
     let mut columns = HashMap::new();
     for variant in Self::nonfirst_variants() {
        columns.insert(variant, cb.binary_columns::<1>(cs)[0]);
     }
     let config = Self { columns };
     cb.assert(
        "sum of binary columns in OneHot is 0 or 1",
        config.sum(0).or(!config.sum(0)),
     );
     config
   }

```
_[Figure 9.1: mpt-circuit/src/gadgets/one_hot.rs#14–30](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/src/gadgets/one_hot.rs#L14-L30)_

The reason the BinaryQuery values are not constrained to be Boolean is because the
```
BinaryColumn configuration does not constrain the advice values to be Boolean, and the

```
configuration is simply a type wrapper around the Column<Advice> type. This provides no
guarantees to the users of this API, who might assume that these values are guaranteed to
be Boolean.
```
 pub fn configure<F: FieldExt>(
   cs: &mut ConstraintSystem<F>,
   _cb: &mut ConstraintBuilder<F>,
 ) -> Self {
   let advice_column = cs.advice_column();
   // TODO: constrain to be binary here...
   // cb.add_constraint()
   Self(advice_column)

```
Trail of Bits 33 Scroll zkEVM Circuits Security Assessment


-----

_[Figure 9.2: mpt-circuit/src/constraint_builder/binary_column.rs#29–37](https://github.com/scroll-tech/mpt-circuit/blob/2e216c2d30d35a459f933a58b8002fe817abb1b4/src/constraint_builder/binary_column.rs#L29-L37)_

The OneHot primitive is used to implement the Merkle path–checking state machine,
including critical properties such as requiring the key and other_key columns to remain
unchanged along a given Merkle path calculation, as shown in figure 9.3.
```
 cb.condition(
   !segment_type.current_matches(&[SegmentType::Start, SegmentType::AccountLeaf3]),
   |cb| {
     cb.assert_equal(
        "key can only change on Start or AccountLeaf3 rows",
        key.current(),
        key.previous(),
     );
     cb.assert_equal(
        "other_key can only change on Start or AccountLeaf3 rows",
        other_key.current(),
        other_key.previous(),
     );
   },
 );

```
_[Figure 9.3: mpt-circuit/src/gadgets/mpt_update.rs#170–184](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/src/gadgets/mpt_update.rs#L170-L184)_

We did not develop a proof-of-concept exploit for the path-checking table, so it may be the
case that the constraint in figure 9.3 is not exploitable due to other constraints. However, if
at any point it is possible to match both SegmentType::Start and some other segment
type (such as by setting one OneHot cell to 1 and another to -1), a malicious prover would
be able to change the key partway through and forge Merkle updates.

##### Exploit Scenario
A malicious prover uses the OneHot soundness issue to bypass constraints, ensuring that
the key and other_key columns remain unchanged along a given Merkle path calculation.
This allows the attacker to successfully forge MPT update proofs that update an arbitrary
key.

##### Recommendations
Short term, add constraints that ensure that the advice values from these columns are
Boolean.

Long term, add positive and negative tests ensuring that these constraint builders operate
according to their expectations.

Trail of Bits 34 Scroll zkEVM Circuits Security Assessment


-----

|