2. IsZeroGadget does not constrain the inverse witness when the value is zero|Col2|
|---|---|
|Severity: Informational|Difcfiulty: N/A|
|Type: Cryptography|Finding ID: TOB-SCROLL2-2|
|Target: src/gadgets/is_zero.rs||


##### Description
The IsZeroGadget implementation allows for an arbitrary inverse_or_zero witness
value when the value parameter is 0.

The gadget returns 1 when value is 0; otherwise, it returns 0. The implementation relies
on the existence of an inverse for when value is nonzero and on correctly constraining
that value * (1 - value * inverse_or_zero) == 0.

However, when value is 0, the constraint is immediately satisfied, regardless of the value
of the inverse_or_zero witness. This allows an arbitrary value to be provided for that
witness value.
```
 pub fn configure<F: FieldExt>(
   cs: &mut ConstraintSystem<F>,
   cb: &mut ConstraintBuilder<F>,
   value: AdviceColumn, // TODO: make this a query once Query is
 clonable/copyable.....
 ) -> Self {
   let inverse_or_zero = AdviceColumn(cs.advice_column());
   cb.assert_zero(
     "value is 0 or inverse_or_zero is inverse of value",
     value.current() * (Query::one() - value.current() *
 inverse_or_zero.current()),
   );
   Self {
     value,
     inverse_or_zero,
   }
 }

```
_[Figure 2.1: mpt-circuit/src/gadgets/is_zero.rs#48–62](https://github.com/scroll-tech/mpt-circuit/blob/7b56d0b323e92ac11e54213520f6e7db41941cd0/src/gadgets/is_zero.rs#L48-L62)_

##### Recommendations
Short term, ensure that the circuit is deterministic by constraining inverse_or_zero to
equal 0 when value is 0.

Trail of Bits 17 Scroll zkEVM Circuits Security Assessment


-----

Long term, document which circuits have nondeterministic witnesses; over time, constrain
them so that all circuits have deterministic witnesses.

Trail of Bits 18 Scroll zkEVM Circuits Security Assessment


-----

|