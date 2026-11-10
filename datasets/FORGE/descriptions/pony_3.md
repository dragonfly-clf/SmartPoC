#### CO - Code Optimization

**Criticality** minor

**Location** contract.sol#L698, 907, 1077, 1242, 1248

##### Description

There are code segments that could be optimized. A segment may be optimized so
that it becomes a smaller size, consumes less memory, executes more rapidly, or
performs fewer operations. teamDivisor is fixed to 0 so the calculation will always
return 0.

|Criticality|minor|
|---|---|
|Location|contract.sol#L698, 907, 1077, 1242, 1248|

```
uint256 public teamDivisor = 0;

```
```
uint256 _rtotransferrteam = ronePart.mul(teamDivisor);
uint256 _ttotransferrteam = tonePart.mul(teamDivisor);
rFee = rFee.sub(_rtotransferrteam);
tFee = tFee.sub(_ttotransferrteam);

```

Contract owner has the authority to manipulate the fees by calling the
setTaxFeePercent and setLiquidityFeePercent functions. But, the fees are set
through _transfer function on each transaction.

```
if(to == address(uniswapV2Pair) ) {
       // apply sell fee
       setSellFee();
}else{
       if(_msgSender() != address(uniswapV2Pair)){
         setTransferFee();
       }else{
         removeAllFee();
       }
}

```

-----

```
function setSellFee() internal {
    isSell = true;
    _taxFee = 9;
    _liquidityFee = 6;
  }

```
```
function setTransferFee() internal {
    isSell = false;
    _taxFee = 4;
    _liquidityFee = 1;
  }

```

##### Recommendation

Rewrite some code segments so the runtime will be more performant.


-----

