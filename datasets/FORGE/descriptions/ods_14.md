#### RS - Redundant Swaps


#### Description


There are code segments that could be optimized. A segment may be optimized so that it


becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer


operations.


The `swapTokensAtAmount` variable can be set to zero since there is no input


validation. As a result, the contract will perform redundant swaps.


#### Recommendation


The team is advised to take these segments into consideration and rewrite them so the


runtime will be more performant. That way it will improve the efficiency and performance of


the source code and reduce the cost of executing it. The contract could embody a check

for not allowing setting the `swapTokensAtAmount` less than a reasonable amount. A

suggested implementation could check that the minimum amount should be more than a


fixed percentage of the total supply.


-----

