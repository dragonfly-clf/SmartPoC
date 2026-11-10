#### MDG - Misleading Digit Grouping


#### Description


The code attempts to assign the value of totalSupply to a constant, representing a total


supply of tokens. However the assignment of the variable totalSupply contains a misleading


usage of the '_' symbol when it groups the digits by four at the end of the totalSupply


number.


#### Recommendation


The team is recommended to use the '_' symbol to separate digits in sets of three. This


practice enhances code comprehension and facilitates better understanding, particularly


when working with large numbers.


-----

