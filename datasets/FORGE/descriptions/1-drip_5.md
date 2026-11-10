#### RSW - Redundant Storage Writes

**Criticality** Minor / Informative

**Location** DripToken.sol#L208,294,233

**Status** Unresolved

#### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations.

The contract updates the isFeeExempt status of an account even if its current state is the

same as the one passed as an argument. As a result, the contract performs redundant

storage writes.
```
   function updateRouter(address _router) external onlyOwner {
      uniswapV2Router = IUniswapV2Router(_router);
   }
   function _setAllFees(uint256 _comboFee, uint256
 _reflectionFee) internal {
      comboFee = _comboFee;
      reflectionFee = _reflectionFee;
   }
   function manage_excludeFromFee(address[] calldata
 addresses, bool status) external onlyOwner {
      for (uint256 i; i < addresses.length; ++i) {
        isFeeExempt[addresses[i]] = status;
      }

#### Recommendation

```
The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it.


-----

