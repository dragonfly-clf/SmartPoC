Medium-risk

 1 medium-risk code issues found

 Should be fixed, could bring problems.

1. Owner can set fees up to 49%
```
        function setFees(uint256 _liquidityFee, uint256 _charityFee, uint256
        _marketingFee, uint256 _projectFee, uint256 _buyBackFee, uint256
        _feeDenominator) external authorized {
            liquidityFee = _liquidityFee;
            charityFee = _charityFee;
            marketingFee = _marketingFee;
            projectFee = _projectFee;
            buyBackFee = _buyBackFee;
            totalFee =
        _liquidityFee.add(_charityFee).add(_marketingFee).add(_projectFee).add(_buyBackF
        ee);
            feeDenominator = _feeDenominator;
            require(totalFee < feeDenominator/2, "Fees cannot be more than 50%");
          }

```

-----

#### 