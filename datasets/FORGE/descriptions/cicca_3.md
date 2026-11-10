#### MEM - Misleading Error Messages

**Criticality** Minor / Informative

**Location** CiccaDefi.sol#L477

**Status** Unresolved

#### Description

The contract is using misleading error messages. These error messages do not accurately

reflect the problem, making it difficult to identify and fix the issue. As a result, the users will

not be able to find the root cause of the error.

The contract is designed to allow the owner to lock the contract for a specified amount of

time using the `lock` function. This function sets the `_lockTime` variable by adding

the provided time parameter to the current `block.timestamp . However, while the`

unlock function's error message suggests that the contract is locked for 7 days, there is no

actual check in the `lock` function to ensure that the value of the time parameter, and

consequently the `_lockTime` variable, is equal to or greater than 7 days. As a result the

`_lockTime` could be set to any value, even lower than the 7 days period.
```
   function lock(uint256 time) public virtual onlyOwner {
      _previousOwner = _owner;
      _owner = address(0);
      _lockTime = block.timestamp + time;
      emit OwnershipTransferred(_owner, address(0));
   }
   function unlock() public virtual {
      require(_previousOwner == msg.sender, "You don't have
 permission to unlock");
      require(block.timestamp > _lockTime, "Contract is
 locked until 7 days");
      emit OwnershipTransferred(_owner, _previousOwner);
      _owner = _previousOwner;
   }

#### Recommendation

```

-----

The team is suggested to provide a descriptive message to the errors. This message can be

used to provide additional context about the error that occurred or to explain why the

contract execution was halted. This can be useful for debugging and for providing more

information to users that interact with the contract. It is recommended that if the intended

functionality is to set the `_lockTime` variable to a minimum of 7 days, then the `lock`

function should embody a check to prevent the setting of the `_lockTime` variable to a

value lower than 7 days. This can be achieved by adding a require statement in the `lock`

function to validate the time parameter.


-----

