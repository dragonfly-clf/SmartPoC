#### RED - Redundant Event Declaration


#### Description


There are code segments that could be optimized. A segment may be optimized so that it


becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer


operations.


The contract declares the events `SwapAndLiquify` and


`SwapTokensAtAmountUpdated` but they are not used in the contract. As a result, both


events are redundant.


#### Recommendation


The team is advised to take these segments into consideration and rewrite them so the


runtime will be more performant. That way it will improve the efficiency and performance of


the source code and reduce the cost of executing it.


-----

