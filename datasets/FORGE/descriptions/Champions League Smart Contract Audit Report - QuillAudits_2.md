### Low level severity issues

##### 1. Variable shadowing

 Check: shadowing-state Severity: High Confidence: High

 CLEToken.allowance.owner (local variable @ CLE.sol#) shadows:
 - Ownable.owner (function @ CLE.sol#410-412)

 CLEToken._approve.owner (local variable @ CLE.sol#) shadows:
 - Ownable.owner (function @ CLE.sol#410-412)

 Remove the state variable shadowing.

 Status: Open

 2. Calls Inside a loop 

 Check: calls-loop Severity: Low Confidence: Medium

###### 04


-----

##### function includeInReward(address account) external onlyOwner() {     require(_isExcluded[account], "Account is already included");     for (uint256 i = 0; i < _excluded.length; i++) { if (_excluded[i] == account) { _excluded[i] = _excluded[_excluded.length - 1]; _tOwned[account] = 0; _isExcluded[account] = false; _excluded.pop(); break; }     }   }  _excluded.pop();

 Calls inside a loop might lead to a denial-of-service attack.

 Recommendation Favor pull over push strategy for external calls.

 Status: Open

 3. Functions that can be declared external

 Ownable.renounceOwnership (CLE.sol#429-432) should be declared external Ownable.transferOwnership (CLE.sol#438-442) should be declared external Ownable.geUnlockTime (CLE.sol#444-446) should be declared external Ownable.lock (CLE.sol#449-454) should be declared external Ownable.unlock (CLE.sol#457-462) should be declared external CLEToken.totalSupply (CLE.sol#754-756) should be declared external IERC20.totalSupply (CLE.sol#48) should be declared external IERC20.transfer (CLE.sol#62) should be declared external CLEToken.transfer (CLE.sol#763-766) should be declared external CLEToken.allowance (CLE.sol#) should be declared external IERC20.allowance (CLE.sol) should be declared external CLEToken.approve (CLE.sol#) should be declared external IERC20.approve (CLE.sol#) should be declared external

###### 05


-----

##### CLEToken.transferFrom (CLE.sol#) should be declared external IERC20.transferFrom (CLE.sol#98) should be declared external CLEToken.name (CLE.sol#742-744) should be declared external CLEToken.symbol (CLE.sol#746-748) should be declared external CLEToken.decimals (CLE.sol#750-752) should be declared external CLEToken.increaseAllowance (CLE.sol#783-786) should be declared external CLEToken.decreaseAllowance (CLE.sol#788-791) should be declared external CLEToken.isExcludedFromReward (CLE.sol#) should be declared external CLEToken.totalFees (CLE.sol#) should be declared external CLEToken.deliver (CLE.sol#) should be declared external CLEToken.reflectionFromToken (CLE.sol#) should be declared external CLEToken.excludeFromReward (CLE.sol#) should be declared external CLEToken.excludeFromFee (CLE.sol#) should be declared external CLEToken.includeInFee (CLE.sol) should be declared external CLEToken.setSwapAndLiquifyEnabled (CLE.sol) should be declared external CLEToken.isExcludedFromFee (CLE.sol#) should be declared external

 Status: Open

###### 06


-----

## Automated Testing

