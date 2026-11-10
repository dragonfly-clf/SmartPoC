#### RCS - Redundant Code Segment


#### Description


There are code segments that could be optimized. A segment may be optimized so that it


becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer


operations.


The contract sends the amount of dividends that are bought and sold to the dividend


tracker contract. The variables `dividendsFromBuy` and `dividendsFromSell` are


initialized with no given value. Hence, both variables will have their default value which is


zero. Since their value will be zero, the `if` statement will never execute. As a result, this


code segment is redundant.


#### Recommendation


The team is advised to take these segments into consideration and rewrite them so the


runtime will be more performant. That way it will improve the efficiency and performance of


the source code and reduce the cost of executing it.


-----

