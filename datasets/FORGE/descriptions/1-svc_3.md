#### CO - Code Optimization

**Criticality** minor

**Location** contract.sol#L891

##### Description

The sellPath configuration is defined in every transaction but it is used only when
the contract balance is sufficient for swap. This produces unnecessary gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L891|

```
address[] memory sellPath = new address[](2);
sellPath[0] = address(this);
sellPath[1] = uniswapV2Router02.WETH();

```

##### Recommendation

The sellPath configuration could be moved to the statements of the swap branch.


-----

