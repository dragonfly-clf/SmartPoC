6. The NonceChanged configuration circuit does not constrain the new value nonce value|Col2|
|---|---|
|Severity: High|Difcfiulty: Low|
|Type: Cryptography|Finding ID: TOB-SCROLL2-6|
|Target: src/gadgets/mpt_update.rs||


##### Description
The NonceChanged configuration circuit does not constrain the config.new_value
parameter to be 8 bytes. Instead, there is a duplicated constraint for config.old_value:
```
 SegmentType::AccountLeaf3 => {
   cb.assert_zero("direction is 0", config.direction.current());
   let old_code_size = (config.old_hash.current() - config.old_value.current())
     * Query::Constant(F::from(1 << 32).square().invert().unwrap());
   let new_code_size = (config.new_hash.current() - config.new_value.current())
     * Query::Constant(F::from(1 << 32).square().invert().unwrap());
   cb.condition(
     config.path_type.current_matches(&[PathType::Common]),
     |cb| {
        cb.add_lookup(
          "old nonce is 8 bytes",
          [config.old_value.current(), Query::from(7)],
          bytes.lookup(),
        );
        cb.add_lookup(
          "new nonce is 8 bytes",
          [config.old_value.current(), Query::from(7)],
          bytes.lookup(),
        );

```
_[Figure 6.1: mpt-circuit/src/gadgets/mpt_update.rs#1209–1228](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/src/gadgets/mpt_update.rs#L1209-L1228)_

This means that a malicious prover could update the Account node with a value of
arbitrary length for the Nonce and Codesize parameters.

The same constraint (with a correct label but incorrect value) is used in the ExtensionNew
path type:
```
 cb.condition(
   config.path_type.current_matches(&[PathType::ExtensionNew]),
   |cb| {
     cb.add_lookup(

```
Trail of Bits 26 Scroll zkEVM Circuits Security Assessment


-----

_[Figure 6.2: mpt-circuit/src/gadgets/mpt_update.rs#1241–1248](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/src/gadgets/mpt_update.rs#L1241-L1248)_

##### Exploit Scenario
A malicious prover uses the NonceChanged proof to update the nonce with a larger than
expected value.

##### Recommendations
Short term, enforce the constraint for the config.new_value witness.

Long term, add positive and negative testing of the edge cases present in the specification.
For both the Common and ExtensionNew path types, there should be a negative test that
fails because it changes the new nonce to a value larger than 8 bytes. Use automated
testing tools like Semgrep to find redundant and duplicate constraints, as these could
indicate that a constraint is incorrect.

Trail of Bits 27 Scroll zkEVM Circuits Security Assessment


-----

|