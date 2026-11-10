#### L01 - Public Function could be Declared External

###### Criticality minor

 Location contract.sol#L1700,1709,1714,1721,1725,1729,1736,2092,2096,2100,2104,2112, 2116,2121,2126,2130,2143,2147,2150,2153,2159,2164,2176,2180,2184,2187,219 0,2194,2199,2202,2213,2218

##### Description

###### Public functions that are never called by the contract should be declared external to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1700,1709,1714,1721,1725,1729,1736,2092,2096,2100,2104,2112, 2116,2121,2126,2130,2143,2147,2150,2153,2159,2164,2176,2180,2184,2187,219 0,2194,2199,2202,2213,2218|

```
transferFrom
transfer
startSwap
stopSwap
firstLaunch
setMarketFee
setBurnFee
startAddLP
setSwapAndLiquifyByLimitOnly

###### ...

```

##### Recommendation

###### Use the external attribute for functions never called from the contract.


-----

