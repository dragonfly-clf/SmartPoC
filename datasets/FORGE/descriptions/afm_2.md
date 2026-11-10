#### RMT - Redundant Multisign Trigger

|Criticality|Minor / Informative|
|---|---|
|Location|AFM.sol#L1285|
|Status|Unresolved|


##### Description


The method setMaxWalletPercent sets the _maxWalletToken using a
double-signature pattern. When the initial sign process is triggered, the
```
maxWallPercent is not validated. Later, in the second signature step, it is validated.

```
As a result, if the maxWallPercent value in the initial sign is not valid, the
multi-signature mechanism will be triggered even if it will not be possible to set the
value.


##### Recommendation


-----

The setMaxWalletPercent value should be checked before the initial trigger of the
multi-sign process.


-----

