1. Vulnerability: Costly loops
   massUpdatePools may run out-of-gas if too many tokens are added. This
   may have implications on calling functions add and set.
   Lines: MasterChef#1496-1501

```
```
function massUpdatePools() public {
  uint256 length = poolInfo.length;
  for (uint256 pid = 0; pid < length; ++pid) {
    updatePool(pid);
  }
}

```
```
Lowest / Code style / Best Practice
 