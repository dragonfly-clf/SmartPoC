#### Informational issues


Issue File Type Line Description

#1 Main State variables that 705, 703, Add the `constant`
could be declared 704, 721 attributes to state variables
constant (constable- that never change
states)

#2 Main Unused return values 1110 Ensure that all the return

values of the function calls
are used and handle both
success and failure cases if
needed by the business logic

#3 Main Ownership can get 397 If owner transfer/renounce
back by previous owner ownership after locking

ownership the previous
owner is still set

Prevent previous owner to
getting back ownership after
transfer/renouncing

#4 Main Wrong comment 465 Locktime can be higher than

7 days

Modify comment for require
statement

#### Commented Code exist

###### There are some instances of code being commented out in the following files that should be removed:


Line Comment

196 // assert(a == b * c + a % b); // There is no case in which this doesn't hold

471, 490, // pragma solidity >=0.5.0;
543, 641

849 // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not
exclude Uniswap router.');

##### Recommendation

###### Remove the commented code, or address them properly.


24

|Issue|File|Type|Line|Description|
|---|---|---|---|---|
|#1|Main|State variables that could be declared constant (constable- states)|705, 703, 704, 721|Add the `constant` attributes to state variables that never change|
|#2|Main|Unused return values|1110|Ensure that all the return values of the function calls are used and handle both success and failure cases if needed by the business logic|
|#3|Main|Ownership can get back by previous owner|397|If owner transfer/renounce ownership after locking ownership the previous owner is still set Prevent previous owner to getting back ownership after transfer/renouncing|
|#4|Main|Wrong comment|465|Locktime can be higher than 7 days Modify comment for require statement|

|Line|Comment|
|---|---|
|196|// assert(a == b * c + a % b); // There is no case in which this doesn't hold|
|471, 490, 543, 641|// pragma solidity >=0.5.0;|
|849|// require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');|


Main Unused return values 1110 Ensure that all the return

values of the function calls
are used and handle both
success and failure cases if
needed by the business logic

Main Ownership can get 397 If owner transfer/renounce
back by previous owner ownership after locking

ownership the previous
owner is still set

Prevent previous owner to
getting back ownership after
transfer/renouncing

Main Wrong comment 465 Locktime can be higher than

7 days

Modify comment for require
statement

#### Commented Code exist

###### There are some instances of code being commented out in the following files that should be removed:


Comment

196 // assert(a == b * c + a % b); // There is no case in which this doesn't hold

// pragma solidity >=0.5.0;

849 // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not
exclude Uniswap router.');