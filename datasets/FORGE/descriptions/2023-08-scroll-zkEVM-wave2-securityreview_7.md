8. The “invalid creation” error handling circuit is unconstrained|Col2|
|---|---|
|Severity: High|Difcfiulty: Medium|
|Type: Cryptography|Finding ID: TOB-SCROLL2-8|
|Target: evm_circuit/execution/error_invalid_creation_code.rs||


##### Description
The “invalid creation” error handling circuit does not constrain the first byte of the actual
memory to be 0xef as intended. This allows a malicious prover to redirect the EVM
execution to a halt after the CREATE opcode is called, regardless of the memory value.

The ErrorInvalidCreationCodeGadget circuit was updated to accommodate the
memory addressing optimizations. However, in doing so, the first_byte witness value
that was bound to the memory’s first byte is no longer bound to it. Therefore, a malicious
prover can always satisfy the circuit constraints, even if they are not in an error state after
the CREATE opcode is called.
```
 fn configure(cb: &mut EVMConstraintBuilder<F>) -> Self {
   let opcode = cb.query_cell();
   let first_byte = cb.query_cell();
   //let address = cb.query_word_rlc();
   let offset = cb.query_word_rlc();
   let length = cb.query_word_rlc();
   let value_left = cb.query_word_rlc();
   cb.stack_pop(offset.expr());
   cb.stack_pop(length.expr());
   cb.require_true("is_create is true", cb.curr.state.is_create.expr());
   let address_word = MemoryWordAddress::construct(cb, offset.clone());
   // lookup memory for first word
   cb.memory_lookup(
     0.expr(),
     address_word.addr_left(),
     value_left.expr(),
     value_left.expr(),
     None,
   );
   // let first_byte = value_left.cells[address_word.shift()];
   // constrain first byte is 0xef
   let is_first_byte_invalid = IsEqualGadget::construct(cb, first_byte.expr(),

```
Trail of Bits 31 Scroll zkEVM Circuits Security Assessment


-----

_[Figure 8.1: evm_circuit/execution/error_invalid_creation_code.rs#36–67](https://github.com/scroll-tech/zkevm-circuits/blob/fc6c8a2972870e62e96cde480b3aa48c0cc1303d/zkevm-circuits/src/evm_circuit/execution/error_invalid_creation_code.rs#L36-L67)_

##### Exploit Scenario
A malicious prover generates two different proofs for the same transaction, one leading to
the error state, and the other successfully executing the CREATE opcode. Distributing these
proofs to two ends of a bridge leads to state divergence and a loss of funds.

##### Recommendations
Short term, bind the first_byte witness value to the memory value; ensure that the
successful CREATE end state checks that the first byte is different from 0xef.

Long term, investigate ways to generate malicious traces that could be added to the test
suite; every time a new soundness issue is found, create such a malicious trace and add it
to the test suite.

Trail of Bits 32 Scroll zkEVM Circuits Security Assessment


-----

|