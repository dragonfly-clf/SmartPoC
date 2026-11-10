7. The Copy circuit does not totally enforce the tag values|Col2|
|---|---|
|Severity: Informational|Difcfiulty: N/A|
|Type: Cryptography|Finding ID: TOB-SCROLL2-7|
|Target: src/copy_circuit/copy_gadgets.rs||


##### Description
The Copy table includes a tag column that indicates the type of data for that particular row.
However, the Copy circuit tag validation function does not totally ensure that the tag
matches one of the predefined tag values.

The implementation uses the copy_gadgets::constrain_tag function to bind the
```
is_precompiled, is_tx_calldata, is_bytecode, is_memory, and is_tx_log

```
witnesses to the actual tag value. However, the code does not ensure that exactly one of
these Boolean values is true.
```
 #[allow(clippy::too_many_arguments)]
 pub fn constrain_tag<F: Field>(
   meta: &mut ConstraintSystem<F>,
   q_enable: Column<Fixed>,
   tag: BinaryNumberConfig<CopyDataType, 4>,
   is_precompiled: Column<Advice>,
   is_tx_calldata: Column<Advice>,
   is_bytecode: Column<Advice>,
   is_memory: Column<Advice>,
   is_tx_log: Column<Advice>,
 ) {
   meta.create_gate("decode tag", |meta| {
     let enabled = meta.query_fixed(q_enable, CURRENT);
     let is_precompile = meta.query_advice(is_precompiled, CURRENT);
     let is_tx_calldata = meta.query_advice(is_tx_calldata, CURRENT);
     let is_bytecode = meta.query_advice(is_bytecode, CURRENT);
     let is_memory = meta.query_advice(is_memory, CURRENT);
     let is_tx_log = meta.query_advice(is_tx_log, CURRENT);
     let precompiles = sum::expr([
        tag.value_equals(
          CopyDataType::Precompile(PrecompileCalls::Ecrecover),
          CURRENT,
        )(meta),
        tag.value_equals(CopyDataType::Precompile(PrecompileCalls::Sha256),
 CURRENT)(meta),
        tag.value_equals(
          CopyDataType::Precompile(PrecompileCalls::Ripemd160),
          CURRENT,

```
Trail of Bits 28 Scroll zkEVM Circuits Security Assessment


-----

_[Figure 7.1: copy_circuit/copy_gadgets.rs#13–62](https://github.com/scroll-tech/zkevm-circuits/blob/fc6c8a2972870e62e96cde480b3aa48c0cc1303d/zkevm-circuits/src/copy_circuit/copy_gadgets.rs#L13-L62)_

In fact, the tag value could equal CopyDataType::RlcAcc, as in the SHA3 gadget. The
```
CopyDataType::Padding value is also not currently matched.

```
In the current state of the codebase, this issue does not appear to cause any soundness
issues because the lookups into the Copy table either use a statically set source and
destination tag or, as in the case of precompiles, the value is correctly bounded and does
not pose an avenue of attack for a malicious prover.

We also observe that the Copy circuit specification mentions a witness value for the
```
is_rlc_acc case, but this is not reflected in the code.

##### Recommendations
```
Short term, ensure that the tag column is fully constrained. Review the circuit specification
and match the implementation with the specification, documenting possible optimizations
that remove constraints and detailing why they do not cause soundness issues.

Trail of Bits 29 Scroll zkEVM Circuits Security Assessment


-----

Long term, include negative tests for an unintended tag value.

Trail of Bits 30 Scroll zkEVM Circuits Security Assessment


-----

|