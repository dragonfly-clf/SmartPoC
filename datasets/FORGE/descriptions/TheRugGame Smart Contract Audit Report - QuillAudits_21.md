1. Incorrect variable added to array

 Description

 The day was being passed in the array instead of the gameEndTime on line: 346 in the Factory contract. Which meant that for example 31, 32, 33 was being passed instead of 31, 63 and so on. Due to this the rug pull was possible of all the three scenarios of 31, 32 and 33 when 63 was assigned as a value.

 Recommendation

 It was recommended and fixed by passing gameEndTime into the array by the developer on line: 378

 Status

 Resolved


-----

###### 