Numeric Notation Best Practices (1 Item)
The numeric notation used in this contract is unconventional, possibly
worsening the reading/debugging experience.

```
|Function|Severity|Relevant Snippet|
|---|---|---|
|Issue Location in Code SlappyCat.includeInReward( address) (SlappyCat.sol#548-559) has costly operations inside a loop: - _excluded.pop() (SlappyCat.sol#555)|Severity : High|function includeInReward(address account) external onlyOwner() { require(_isExcluded[account], "Account is already included"); for (uint256 i = 0; i < _excluded.length; i++) { if (_excluded[i] == account) { _excluded[i] = _excluded[_excluded.length - 1]; _tOwned[account] = 0; _isExcluded[account] = false; _excluded.pop(); break; } } }|

|Function|Severity|Relevant Snippet|
|---|---|---|
|Contract SlappyCat uses literals with too many digits: - DEAD = 0x000000000000000000000000 000000000000dEaD (SlappyCat.sol#381)|Severity : High|address private constant DEAD = 0x0000000000000000000000000000 00000000dEaD;|


-----

```
 