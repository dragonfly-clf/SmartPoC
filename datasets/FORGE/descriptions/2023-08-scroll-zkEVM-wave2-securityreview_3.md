4. Discrepancies between the MPT circuit specification and implementation|Col2|
|---|---|
|Severity: Informational|Difcfiulty: N/A|
|Type: Cryptography|Finding ID: TOB-SCROLL2-4|
|Target: Several flies||


##### Description
The MPT circuit implementation is not faithful to the circuit specification in many areas and
does not contain comments for the constraints that are either missing from the
implementation or that diverge from those in the specification.

The allowed segment transitions depend on the proof type. For the NonceChanged proof
type, the specification states that the Start segment type can transition to Start and that
the AccountLeaf0 segment type also can transition to Start. However, neither of these
paths is allowed in the implementation.
```
 MPTProofType::NonceChanged
 | MPTProofType::BalanceChanged
 | MPTProofType::CodeSizeExists
 | MPTProofType::CodeHashExists => [
   (
     SegmentType::Start,
     vec![
        SegmentType::AccountTrie, // mpt has > 1 account
        SegmentType::AccountLeaf0, // mpt has <= 1 account
     ],
   ),
   (
     SegmentType::AccountTrie,
     vec![
        SegmentType::AccountTrie,
        SegmentType::AccountLeaf0,
        SegmentType::Start, // empty account proof
     ],
   ),
   (SegmentType::AccountLeaf0, vec![SegmentType::AccountLeaf1]),
   (SegmentType::AccountLeaf1, vec![SegmentType::AccountLeaf2]),
   (SegmentType::AccountLeaf2, vec![SegmentType::AccountLeaf3]),
   (SegmentType::AccountLeaf3, vec![SegmentType::Start]),

```
_[Figure 4.1: mpt-circuit/src/gadgets/mpt_update/segment.rs#20–42](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/src/gadgets/mpt_update/segment.rs#L20-L42)_

Trail of Bits 21 Scroll zkEVM Circuits Security Assessment


-----

_[Figure 4.2: Part of the MPT specification (spec/mpt-proof.md#L318-L328)](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/spec/mpt-proof.md#L318-L328)_

The transitions allowed for the PoseidonCodeHashExists proof type also do not match:
the specification states that it has the same transitions as the NonceChanged proof type,
but the implementation has different transitions.

The key depth direction checks also do not match the specification. The specification states
that the depth parameter should be used but the implementation uses depth - 1.
```
 cb.condition(is_trie.clone(), |cb| {
   cb.add_lookup(
     "direction is correct for key and depth",
     [key.current(), depth.current() - 1, direction.current()],
     key_bit.lookup(),
   );
   cb.assert_equal(
     "depth increases by 1 in trie segments",
     depth.current(),
     depth.previous() + 1,
   );
   cb.condition(path_type.current_matches(&[PathType::Common]), |cb| {
     cb.add_lookup(
        "direction is correct for other_key and depth",
        [
          other_key.current(),
          depth.current() - 1,

```
_[Figure 4.3: mpt-circuit/src/gadgets/mpt_update.rs#188–205](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/src/gadgets/mpt_update.rs#L188-L205)_

Trail of Bits 22 Scroll zkEVM Circuits Security Assessment


-----

_[Figure 4.4: Part of the MPT specification (spec/mpt-proof.md#L279-L282)](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/spec/mpt-proof.md#L279-L282)_

Finally, the specification states that when a segment type is a non-trie type, the value of
```
key should be constrained to 0, but this constraint is omitted from the implementation.
 cb.condition(!is_trie, |cb| {
   cb.assert_zero("depth is 0 in non-trie segments", depth.current());
 });

```
_[Figure 4.5: mpt-circuit/src/gadgets/mpt_update.rs#212–214](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/src/gadgets/mpt_update.rs#L212-L214)_

_[Figure 4.6: Part of the MPT specification (spec/mpt-proof.md#L284-L286)](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/spec/mpt-proof.md?plain=1#L284C2-L286)_

##### Recommendations
Short term, review the specification and ensure its consistency. Match the implementation
with the specification, and document possible optimizations that remove constraints,
detailing why they do not cause soundness issues.

Long term, include both positive and negative tests for all edge cases in the specification.

Trail of Bits 23 Scroll zkEVM Circuits Security Assessment


-----

|