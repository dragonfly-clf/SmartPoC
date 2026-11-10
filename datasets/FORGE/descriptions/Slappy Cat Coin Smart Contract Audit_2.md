Function Initializing State Variables (2 Items)
Some state variables in this contract can be set through dynamic functions
calls, which may be unsafe

```
|Function|Severity|Relevant Snippet|
|---|---|---|
|Issue Location in Code SlappyCat.constructor().ro uter (SlappyCat.sol#402) is a local variable never initialized|Severity : High|address router;|

|Function|Severity|Relevant Snippet|
|---|---|---|
|Issue Location in Code SlappyCat._tTotal (SlappyCat.sol#357) is set pre-construction with a non-constant function or state variable: - 420_690_000_000_000 * (10 ** _decimals)|Severity : High|uint256 private _tTotal = 420_690_000_000_000 * (10 ** _decimals);|


-----

|Issue Location in Code SlappyCat._rTotal (SlappyCat.sol#358) is set pre-construction with a non-constant function or state variable: - (MAX - (MAX % _tTotal))|Severity : High|uint256 private _rTotal = (MAX - (MAX % _tTotal));|
|---|---|---|

```
 