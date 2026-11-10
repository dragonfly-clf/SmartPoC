1. Possible Manipulation of distributeRewardsAndRugLoser()

 Description

 performUpkeep() is a public function which can be called by anyone but contains a critical function distributeRewardsAndRugLoser(). This can be exploited by anyone to Rug losers quickly in short span of time by directly calling the performUpKeep function, resulting in the game to get over earlier than expected. This could also result in Denial of service and unfair manipulation of the game.

 Remediation

 Consider reviewing the business and operational logic in order to avoid this issue.

 Status

 Resolved


-----

###### Medium Severity Issues

 