#### Low issues


File Type Line Description

Main Contract doesn’t  - We recommend to import all
import npm packages packages from npm directly
from source (like without flatten the contract.
OpenZeppelin etc.) Functions could be modified

or can be susceptible to
vulnerabilities

Main A floating pragma is set 21 The current pragma Solidity

directive is „“^0.”8.4”.

Main Missing Zero Address 322, 329132 Check that the address is not
Validation (missing- zero
zero-check)

Main Local variables 246, 225 Rename the local variables


###### 22


-----

|#1|Main|State variables that could be declared constant (constable- states)|109|Add the `constant` attributes to state variables that never change|
|---|---|---|---|---|
|#2|Main|Unused state variables|143, 109|Remove unused state variables|
|#3|Main|Naming convention|397, 391|Wrong naming convention - manualSend instead with a lowercase s - manualSwap instead with a lowercase s|
|#4|Main|Rest amount|306|If you send an odd amount to sendETHToFee function there will be a rest amount|
|#5|Main|SafeMath is unnecessary|-|It is not necessary to import SafeMath and use its functions because it is imported automatically in pragma versions above 0.8.x|
|#6|Main|Exclusion of addresses|324, 331|After changing developmentAddress/ marketingAddress you should set isExcludedFromFee to false for the old addresses|


#### Audit Comments

##### 13. January 2022:

###### • Read whole report for more information



###### - manualSend instead with

a lowercase s

###### - manualSwap instead with

a lowercase s

Main Rest amount 306 If you send an odd amount

to sendETHToFee function
there will be a rest amount

Main SafeMath is  - It is not necessary to import
unnecessary SafeMath and use its

functions because it is
imported automatically in
pragma versions above 0.8.x

Main Exclusion of addresses 324, 331 After changing
developmentAddress/
marketingAddress you
should set
isExcludedFromFee to false
for the old addresses

#### Audit Comments

##### 13. January 2022:

###### Read whole report for more information


###### 23


-----

