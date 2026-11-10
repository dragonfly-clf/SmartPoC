Costly Loop Operation (1 Item)
Following looping logic in this contract results in very high gas usage.

```
**Function** **Severity** **Relevant Snippet**
`Issue Location in Code` function includeInReward(address

account) external onlyOwner() {
require(_isExcluded[account],
```
SlappyCat.includeInReward(
```
"Account is already included");
```
address)
```
for (uint256 i = 0; i < _excluded.length;
```
(SlappyCat.sol#548-559) Severity
```
i++) {
```
has costly operations : High
```
if (_excluded[i] == account) {

`inside a loop:` _excluded[i] =

`- _excluded.pop()` _excluded[_excluded.length - 1];
`(SlappyCat.sol#555)` _tOwned[account] = 0;

_isExcluded[account] = false;
_excluded.pop();
break;
}
}
}
```
 