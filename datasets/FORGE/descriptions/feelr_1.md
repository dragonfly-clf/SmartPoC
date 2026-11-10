#### SFV - Swap Functionality Vulnerability


#### Description


As part of the transfer flow, the contract has an implementation of the swap functionality.


However, it lacks a mutex in its implementation. During the swapping process, the


`transfer` function will be called internally. As a consequence of the second swap lacking


a mutex, the contract can fall into an infinite loop, continuously executing the swap


operation. This continuous execution consumes all the available gas and eventually reaches


the limit, causing the transaction to fail and revert.


-----

#### Recommendation


The team is advised to take these segments into consideration and introduce a mutex. This


way the contract will avoid entering an infinite loop, causing the transaction to revert.


#### Team Update


_"The Swap and distribute function doesn’t have a function that can stop an infinite loop but_

_that loop can only happen in case of a bot and even if does happen the transaction wont go_


_through. For a regular investor this doesn’t bother him."_


-----

