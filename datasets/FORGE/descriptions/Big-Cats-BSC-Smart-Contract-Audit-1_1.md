#### Public Functions Should be Declared External (11 Detected Items)

##### Some functions in this contract should be declared as external in order to save gas.

|Function|Severity|Relevant Snippet|
|---|---|---|
|name() should be declared external: - StandardToken.name() (StandardToken.sol#483-485)|Severity: High|function name() public view virtual returns (string memory) { return _name; }|
|symbol() should be declared external: - StandardToken.symbol() (StandardToken.sol#491-493)|Severity: High|function symbol() public view virtual returns (string memory) { return _symbol; }|
|decimals() should be declared external: - StandardToken.decimals() (StandardToken.sol#508-510)|Severity: High|function decimals() public view virtual returns (uint8) { return _decimals; }|
|totalSupply() should be declared external: - StandardToken.totalSupply() (StandardToken.sol#515-517)|Severity: High|function totalSupply() public view virtual override returns (uint256) { return _totalSupply; }|
|balanceOf(address) should be declared external: - StandardToken.balanceOf(address) (StandardToken.sol#522-530)|Severity: High|function balanceOf(address account) public view virtual override returns (uint256) return _balances[account]; }|