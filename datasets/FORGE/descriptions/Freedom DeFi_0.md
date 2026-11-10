####  High Severity Issues

###### 1. Out of gas

 Issue:

 • The function distributeRewards() uses the native token balance to
 calculate reward in FREE token. This may not cause serious troubles due to big decimal difference, but function won’t work properly.
 • https://ropsten.etherscan.io/tx/0xb43ff8cecf627b92b048b88abf9b8d8
 2369d093c551d13c8e55026374da86510
 Recommendation:
 Use balanceOf() function to get proper token amount instead.

