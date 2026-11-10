3. Incorrect initialization of gameEndTime

 Description

 The gameEndTime is incorrectly initialized and is expected to be initialized with respect to the gameStartTime assigned. This is because in the checkUpkeep() function, the gameEndTime is being compared to the block.timestamp which won’t work if gameEndTime is only initialized in terms of days and not gameStartTime . Also on the line: 408 the if statement should check that if the block.timestamp is greater than the current gameEndtime (let's say 70 days) but lesser than the validTime (let's say 110).  This is bcoz if this is not checked properly, you could end up with the else statement never getting executed. This is because even if the block.timestamp has crossed the validTime, the block.timestamp would still be greater than the _gameEndTime and thus only the else if statement will be triggered and not the else statement.

 Recommendation

 It is recommended to initialize the _gameEndTime variable correctly and write the if else statements in the checkUpkeep() function accordingly.

 Status

 Resolved


-----

###### Low Severity Issues

 