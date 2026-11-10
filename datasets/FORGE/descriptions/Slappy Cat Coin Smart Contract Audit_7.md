Public Functions Should be Declared External (15 Items)
Following functions in this contract should be declared as external in
order to save gas.

```
|Function|Severity|Relevant Snippet|
|---|---|---|
|name() should be declared external: - SlappyCat.name() (SlappyCat.sol#454-456)|Severity : High|function name() public view returns (string memory) { return _name; }|
|symbol() should be declared external: - SlappyCat.symbol() (SlappyCat.sol#458-460)|Severity : High|function symbol() public view returns (string memory) { return _symbol; }|
|decimals() should be declared external: - SlappyCat.decimals() (SlappyCat.sol#462-464)|Severity : High|function decimals() public view returns (uint8) { return _decimals; }|