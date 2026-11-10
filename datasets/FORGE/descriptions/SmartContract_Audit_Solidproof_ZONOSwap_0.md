#### Low issues


File Type Line Description

Contract doesn’t       - We recommend to import all
import npm packages packages from npm directly

Factory from source (like without flatten the contract.
Address OpenZeppelin etc.) Functions could be modified

or can be susceptible to
vulnerabilities

Contract doesn’t       - We recommend to import all
import npm packages packages from npm directly

MasterC from source (like without flatten the contract.
hef OpenZeppelin etc.) Functions could be modified

or can be susceptible to
vulnerabilities

Contract doesn’t       - We recommend to import all
import npm packages packages from npm directly

RouterA from source (like without flatten the contract.
ddress OpenZeppelin etc.) Functions could be modified

or can be susceptible to
vulnerabilities


###### 29


-----

|#5|Factory Address|Missing Zero Address Validation (missing- zero-check)|469, 494, 499, 319|Check that the address is not zero|
|---|---|---|---|---|
|#6|MasterC hef|Missing Zero Address Validation (missing- zero-check)|1257, 1477|Check that the address is not zero|
|#7|RouterA ddress|Missing Zero Address Validation (missing- zero-check)|362|Check that the address is not zero|
|#8|ZONOT oken (V2.0)|Missing Zero Address Validation (missing- zero-check)|1347, 1343, 1079, 1357|Check that the address is not zero|
|#9|ZONOT oken (V2.0)|Unused return values|1242|Ensure that all the return values of the function calls are used|
|#10|ZONOT oken (V2.0)|State variable visibility is not set.|989, 1009, 1020, 1021,|It is best practice to set the visibility of state variables explicitly|


#### Informational issues


Issue File Type Line Description

#1 RouterA Functions that are not 26 Remove unused functions
ddress used

#2 ZONOT State variables that 1003, 1002, Add the `constant`
oken could be declared 1018 attributes to state variables
(V2.0) constant that never change

#3 ZONOT Functions that are not 1189, 1194, Remove unused functions
oken used 1172, 1156
(V2.0)

#4 ZONOT Unused state variables 534, 1003 Remove unused state
oken variables
(V2.0)

#### Commented Code exist

###### There are some instances of code being commented out in the following files that should be removed:


File Line Comment

MasterCh 136 // assert(a == b * c + a % b); // There is no case in which this doesn't hold
ef

###### 30

|Issue|File|Type|Line|Description|
|---|---|---|---|---|
|#1|RouterA ddress|Functions that are not used|26|Remove unused functions|
|#2|ZONOT oken (V2.0)|State variables that could be declared constant|1003, 1002, 1018|Add the `constant` attributes to state variables that never change|
|#3|ZONOT oken (V2.0)|Functions that are not used|1189, 1194, 1172, 1156|Remove unused functions|
|#4|ZONOT oken (V2.0)|Unused state variables|534, 1003|Remove unused state variables|

|File|Line|Comment|
|---|---|---|
|MasterCh ef|136|// assert(a == b * c + a % b); // There is no case in which this doesn't hold|


Validation (missing- zero

ddress

zero-check)

ZONOT Missing Zero Address 1347, 1343, Check that the address is not
oken Validation (missing- 1079, 1357 zero
(V2.0) zero-check)

ZONOT Unused return values 1242 Ensure that all the return
oken values of the function calls
(V2.0) are used

ZONOT State variable visibility 989, 1009, It is best practice to set the
oken is not set. 1020, 1021, visibility of state variables
(V2.0) explicitly

