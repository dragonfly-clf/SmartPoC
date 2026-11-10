10. Intermediate columns are not explicit|Col2|
|---|---|
|Severity: Informational|Difcfiulty: N/A|
|Type: Cryptography|Finding ID: TOB-SCROLL2-10|
|Target: src/mpt_update.rs||


##### Description
The MPT update circuit includes two arrays of “intermediate value” columns, as shown in
figure 10.1.
```
 intermediate_values: [AdviceColumn; 10], // can be 4?
 second_phase_intermediate_values: [SecondPhaseAdviceColumn; 10], // 4?

```
_[Figure 10.1: mpt-circuit/src/gadgets/mpt_update.rs#65–66](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/src/gadgets/mpt_update.rs#L65-L66)_

These columns are used as general-use cells for values that are only conditionally needed
in a given row, reducing the total number of columns needed. For example, figure 10.2
shows that intermediate_values[0] is used for the address value in rows that match
```
SegmentType::Start, but as shown in figure 10.3, rows representing the
SegmentType::AccountLeaf3 state of a Keccak code-hash proof use that same slot for

```
the old_high value.
```
 let address = self.intermediate_values[0].current() * is_start();

```
_[Figure 10.2: mpt-circuit/src/gadgets/mpt_update.rs#78](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/src/gadgets/mpt_update.rs#L78)_
```
 SegmentType::AccountLeaf3 => {
   cb.assert_equal("direction is 1", config.direction.current(), Query::one());
   let [old_high, old_low, new_high, new_low, ..] = config.intermediate_values;

```
_[Figure 10.3: mpt-circuit/src/gadgets/mpt_update.rs#1632–1635](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/src/gadgets/mpt_update.rs#L1632-L1635)_

In some cases, cells of intermediate_values are used starting from the end of the
```
intermediate_values column, such as the other_key_hash and
other_leaf_data_hash values in PathType::ExtensionOld rows, as illustrated in

```
figure 10.4.
```
 let [.., key_equals_other_key, new_hash_is_zero] = config.is_zero_gadgets;
 let [.., other_key_hash, other_leaf_data_hash] = config.intermediate_values;
 nonexistence_proof::configure(
   cb,

```
Trail of Bits 35 Scroll zkEVM Circuits Security Assessment