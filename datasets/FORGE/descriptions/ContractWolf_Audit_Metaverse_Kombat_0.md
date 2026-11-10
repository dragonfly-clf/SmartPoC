##### SWC-107 | Reentrancy

Functions _transfer and swapAndLiquify Reentrancy detected through external calls.

**Recommendation**

###### Make sure all internal state changes are performed before the call is executed or; Use Openzeppelin’s ReentrancyGuard


**Recommendation**

###### Make sure all internal state changes are performed before the call is executed or; Use Openzeppelin’s ReentrancyGuard


-----

