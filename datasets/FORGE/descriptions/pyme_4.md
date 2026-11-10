#### RSW - Redundant Storage Writes

**Criticality** Minor / Informative

**Location** PymeToken.sol#L4888,4892

**Status** Unresolved

#### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations.

The contract updates the `whitelist` and `blacklist` status of an account even if

its current state is the same as the one passed as an argument. As a result, the contract

performs redundant storage writes.
```
   function setWhitelist(address _address, bool _state) public
 onlyOwner {
      whitelist[_address] = _state;
   }
   function setBlacklist(address _address, bool _state) public
 onlyOwner {
      blacklist[_address] = _state;
   }

#### Recommendation

```
The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it.


-----

