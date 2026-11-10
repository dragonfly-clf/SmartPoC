1. Centralization issue in rewards and transaction order dependence

 Description

 The rewards to the stakers of TRG tokens, in the STRG contract are sent in terms of TRG tokens. But the STRG contract does not hold the TRG tokens that are expected to be given for reward. This is because, according to the current logic, the TRG tokens are sent after the stakers have staked some amount of tokens. Only after this, the dividendPerToken variable in TRG contract is updated, thus giving non-zero rewards. But these TRG tokens are sent by the admin, which brings in centralization for providing the rewards to the stakers. If the TRG tokens are not sent to STRG contract(after the stakers have staked), then the stakers will get no rewards. 
 Also note that currently it is not possible to send TRG tokens to the STRG contract before any stakers come in. This is because the totalStaked is 0, thus giving a panic on line: 42 in TRG contract. 
 Another issue is that if the TRG tokens are manually sent to the STRG contract each time by the admin for allocating a pool of rewards to the users, an attacker can front run this transaction to deposit a large amount of tokens and then backrun it with withdrawal of his stake, thus sandwiching a substantial amount of rewards, which is unfair to the current stakers(See sandwich attacks).

 Remediation

 It is advised to allocate TRG rewards in the STRG contract prior to any staking begins to prevent unnecessary/unfair frontrun scenarios and review business and operational logic.

 Status

 Resolved


-----

###### Low Severity Issues

 No issues found

 Informational Issues

 