#### L04 - Conformance to Solidity Naming Conventions

**Criticality** minor / informative

**Location** contract.sol#L539,641,596,604,605,606,619,1446,1456,1501,1543,1554,1558,15
62,1575,1580,785,789,790,791,792,796,801,802,804,808,809,810,811,812,814,8
15,817,818,819,820,823,824,825,826,827,829,830,831,834,835,836,839,851,160
9,1625

**Status** Unresolved

##### Description

Solidity defines a naming convention that should be followed. Rule exceptions:

 - Allow constant variable name/symbol/decimals to be lowercase.

 - Allow _ at the beginning of the mixed_case match for private variables and
unused parameters.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L539,641,596,604,605,606,619,1446,1456,1501,1543,1554,1558,15 62,1575,1580,785,789,790,791,792,796,801,802,804,808,809,810,811,812,814,8 15,817,818,819,820,823,824,825,826,827,829,830,831,834,835,836,839,851,160 9,1625|
|Status|Unresolved|

```
WETH
_minPeriod
_minDistribution
_token
BUSD
WBNB
Router
dividendsPerShareAccuracyFactor
_tokenAddress

```
...


##### Recommendation

Follow the Solidity naming convention.
[https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-conventions.](https://docs.soliditylang.org/en/v0.4.25/style-guide.html#naming-convention)


-----

