#### MAL - Misused Algorithmic Logic

**Criticality** critical

**Location** contract.sol#L920

##### Description

The algorithmic flow does not follow the required business logic. In the following
code segment, the rFee is changed (subtraction) before they are removed from the
_rTotal. So, the _rTotal will be reduced by a percentage amount instead of the
current total fees. As a result, the value of the _rTotal will be bigger than the actual
total supply.

|Criticality|critical|
|---|---|
|Location|contract.sol#L920|

```
         uint256 _rtotransferrteam = ronePart.mul(transferTeamfee);
         uint256 _ttotransferrteam = tonePart.mul(transferTeamfee);
         rFee = rFee.sub(_rtotransferrteam);
         tFee = tFee.sub(_ttotransferrteam);
         uint256 _rtotransferrburn = ronePart.mul(burnDivisor);
         uint256 _ttotransferrburn = tonePart.mul(burnDivisor);
         rFee = rFee.sub(_rtotransferrburn);
         tFee = tFee.sub(_ttotransferrburn);
         uint256 _rtotransferrcharity = ronePart.mul(charityDivisor);
         uint256 _ttotransferrcharity = tonePart.mul(charityDivisor);
         rFee = rFee.sub(_rtotransferrcharity);
         tFee = tFee.sub(_ttotransferrcharity);
         _takefunds(teamAddress,_rtotransferrteam,_ttotransferrteam);
         _takefunds(deadAddress,_rtotransferrburn,_ttotransferrburn);
_takefunds(airdropAddress,_rtotransferrcharity,_ttotransferrcharity);
       }
       _rTotal = _rTotal.sub(rFee);
       _tFeeTotal = _tFeeTotal.add(tFee);

```

##### Recommendation

The algorithm should be reshaped so it will match to the business logic.


-----

