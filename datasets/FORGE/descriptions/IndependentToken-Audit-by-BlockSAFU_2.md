High-Risk

 3 high-risk code issues found

 Must be fixed, and will bring problem.

1. Owner can set blacklist
```
        function manage_blacklist(address[] calldata addresses, bool status) external
        onlyOwner {
            require(addresses.length < 501,"GAS Error: max limit is 500 addresses");
            for (uint256 i; i < addresses.length; ++i) {
              isBlacklisted[addresses[i]] = status;
            }
          }

```
2. Owner can set max tx amount
```
        function setMaxTxAbsolute(uint256 amount) external authorized {
            _maxTxAmount = amount;
          }

```
3. Owner can set hidden owner
```
        function authorize(address adr) public onlyOwner {
            authorizations[adr] = true;
          }

#### 