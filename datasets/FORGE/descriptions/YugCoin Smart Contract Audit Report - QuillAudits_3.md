4. BNB stuck in contract can’t be withdrawn

 Description

 When the swapAndLiquify function is called, the token swap (YUG to BNB) that occurs results in a slight price change that makes it require less BNB to stake the other half of the YUG balance. Thus leaving a small amount of BNB left in the contract with no function to get those BNB tokens out. Although none of the functions in the scope of this contract are dependent on the contract BNB balance, the tokens would be technically unusable.

 Remediation

 Make a function to clear out the stuck BNB tokens or find some way to fit into your proposed logic (e.g. distribute to YUG holders, use to buyback YUG tokens etc)

 Status

 Resolved

 Low Severity Issues

 