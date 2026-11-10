#### Commented Code exist

###### There are some instances of code being commented out in the following files that should be removed:


Line Comment

60 // assert(a == b * c + a % b); // There is no case in which this doesn't hold

##### Recommendation

###### Remove the commented code, or address them properly.


#### Switch modifier order

###### _lock_ modifier should be the first modifier in every function because it is a reentrancy guard and should take procedure over any other modifier.


#### Audit Comments

##### 14. December 2021:

###### • Make sure to exclude also pancake swap router address 0x10ED43C718714eb63d5aA57B78B54704E256024E in addBotToBlackList function


23

|Line|Comment|
|---|---|
|60|// assert(a == b * c + a % b); // There is no case in which this doesn't hold|


###### files that should be removed:


Comment

60 // assert(a == b * c + a % b); // There is no case in which this doesn't hold

##### Recommendation

###### Remove the commented code, or address them properly.


