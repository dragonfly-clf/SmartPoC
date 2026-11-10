1. Insufficient checks in Bribe()

 Description

 In function bribe the following if statement is incorrect and Insufficient.     bool isRugged = IERC20(pair).balanceOf(factory) == 0;
 This is not a foolproof way to check if a token in the game has been rugged or not. This is because even if the token is Rugged according the flow, still the factory contract can be sent tokens thus setting the isRugged variable to false even if it should have been true.

 Recommendation

 It is advised to use another way to ensure whether a token has been rugged in the game or not, such as explicitly setting a boolean variable to true or false when the token is rugged.

 Status

 Acknowledged

 Comment: The following issue was resolved by adding a function isValidBribe() in the factory contract which checks if the token was rugged or not.


-----

###### 