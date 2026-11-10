#### CO - Code Optimization

**Criticality** minor

**Location** contract.sol#L555, 607, 616, 626, 634, 643, 648

##### Description

There are code segments that could be optimized. A segment may be optimized so
that it becomes a smaller size, consumes less memory, executes more rapidly, or
performs fewer operations. The contract does not use the blacklisted variable or any
of the functions and modifiers that are in the code segments below.

|Criticality|minor|
|---|---|
|Location|contract.sol#L555, 607, 616, 626, 634, 643, 648|

```
address public blacklister;
mapping(address => bool) internal blacklisted;
event Blacklisted(address indexed _account);
event UnBlacklisted(address indexed _account);
event BlacklisterChanged(address indexed newBlacklister);

```
```
modifier onlyBlacklister() {
  require(msg.sender == blacklister);
  _;
}

```
```
modifier notBlacklisted(address _account) {
  require(blacklisted[_account] == false);
  _;
}

```
```
function isBlacklisted(address _account) public view returns (bool) {
  return blacklisted[_account];
}

```

-----

```
function blacklist(address _account) public onlyBlacklister {
  blacklisted[_account] = true;
  emit Blacklisted(_account);
}

```
```
function unBlacklist(address _account) public onlyBlacklister {
   blacklisted[_account] = false;
   emit UnBlacklisted(_account);
}

```
```
function updateBlacklister(address _newBlacklister) public onlyOwner {
  require(_newBlacklister != address(0));
  blacklister = _newBlacklister;
  emit BlacklisterChanged(blacklister);
}

```

##### Recommendation

Rewrite some code segments so the runtime will be more performant.


-----

