##### Low Severity Issues

###### 1. [#L182-184] function transferOwnership():
 Missing events to track down the transfer of ownership to the newOwner

 Missing Zero Address Validation
 2.

 [#269-278] function transfer(): Missing Zero Address Check for to address
 [#L280-288] function approve(): Missing Zero Address Check for spender address
 [#L290-296]function increaseAllowance(): Missing Zero Address Check for spender address
 [#L298-304]function decreaseAllowance(): Missing Zero Address Check for spender address
 [#306-316] function transferFrom(): Missing Zero Address Check for to and from address

 Missing Zero Token Transfer Validation
 3.

 [#269-278] function transfer(): Add check for tokens > 0
 [#306-316] function transferFrom(): Add check for tokens > 0

 05


-----

