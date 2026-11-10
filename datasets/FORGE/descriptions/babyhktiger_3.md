#### RE - Redundant Event


#### Description


There are code segments that could be optimized. A segment may be optimized so that it


becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer


operations.


the `BuyFeesChanged,` `SellFeesChanged, and`


`WalletToWalletTransferWithoutFeeEnabled` event is not utilized in the contract's


implementation. Hence, it is redundant.


#### Recommendation


The team is advised to take these segments into consideration and rewrite them so the


runtime will be more performant. That way it will improve the efficiency and performance of


the source code and reduce the cost of executing it. It is recommeneded to remove


redundant events.


-----

