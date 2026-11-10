5. Redundant check in tokenTransfer function

 Description

 With all other checks done, !isExcluded[sender] && !isExcluded[recipient] performs the same function as the else clause.

 Recommendation

 Consider removing the redundant check here since it is covered in the else clause.

 Status

 Resolved


-----

###### 