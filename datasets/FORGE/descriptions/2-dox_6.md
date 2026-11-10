#### RFU - Redundant Function Usage

**Criticality** Minor / Informative

**Location** contracts/Twelve_Days_Of_Xmas.sol#L301

**Status** Unresolved

#### Description

The contract contains an `update_fees` function solely used for emitting the

`UpdateFee` event. This function is called within the `setMultipliers` and `setFees`

functions to emit the event after updating fee-related variables. However, the

`update_fees` function itself does not perform any additional logic apart from emitting the

event. This setup introduces an extra layer of function calls that could be streamlined.

Directly emitting the `UpdateFee` event within the `setMultipliers` and `setFees`

functions, instead of calling a separate function to do so, would simplify the contract's

structure and enhance its readability.
```
   function update_fees() internal {
      emit UpdateFee(
 uint8(totalFee.mul(buyMultiplier).div(100)),
        uint8(totalFee.mul(sellMultiplier).div(100)),
        uint8(totalFee.mul(transferMultiplier).div(100))
        );
   }

#### Recommendation

```
It is recommended to emit the `UpdateFee` event directly within the `setMultipliers`

and `setFees` functions, rather than using the intermediary `update_fees` function.

This approach reduces the number of function calls, simplifying the contract's logic flow.

The direct emission of events in the respective functions where changes occur enhances

clarity and makes the contract more straightforward. This modification will not alter the

contract's core functionality but will result in a more efficient and cleaner code structure.


-----

