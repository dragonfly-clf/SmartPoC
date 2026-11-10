##### Informational issues

|Issue|File|Type|Line|Description|
|---|---|---|---|---|
|#1|Main|State variables that could be declared constant (constable- states)|759, 698, 696, 697|Add the `constant` attributes to state variables that never change|
|#2|Main|Unused return values|1434|Ensure that all the return values of the function calls are used and handle both success and failure cases if needed by the business logic|
|#3|Main|Functions that are not used|14, 54, 58, 66, 70, 105, 88, 80|Remove unused functions|
|#4|Main|Unused state variables|698, 78|Remove unused state variables|
|#5|Main|New DividendTracker settings|884-896|New dividend tracker is not - excluded from fee (_isExcludedFromFee, like in L825) - Excluded from max wallet limit (_isExcludedFromMaxWall etLimit, like in L839) - Excluded from max transaction amount (_isExcludedFromMaxTrans actionLimit, like in L835)|


Main State variables that 759, 698, Add the `constant`
could be declared 696, 697 attributes to state variables
constant (constable- that never change
states)

Main Unused return values 1434 Ensure that all the return

values of the function calls
are used and handle both
success and failure cases if
needed by the business logic

Main Functions that are not 14, 54, 58, Remove unused functions
used 66, 70, 105,

88, 80

Main Unused state variables 698, 78 Remove unused state
variables

Main New DividendTracker 884-896 New dividend tracker is not
settings       - excluded from fee

(_isExcludedFromFee, like
in L825)

###### - Excluded from max wallet

limit
(_isExcludedFromMaxWall
etLimit, like in L839)

###### - Excluded from max

transaction amount
(_isExcludedFromMaxTrans
actionLimit, like in L835)


24


-----

|#6|Main|Unnecessary code|659-661|Remove following blue part of function. It’s unreachable function _transfer(address from, address to, uint256 value) internal virtual override { require(false); int256 _magCorrection = magnifiedDividendPerShare. mul(value).toInt256Safe(); magnifiedDividendCorrectio ns[from] = magnifiedDividendCorrectio ns[from].add(_magCorrectio n); magnifiedDividendCorrectio ns[to] = magnifiedDividendCorrectio ns[to].sub(_magCorrection); }|
|---|---|---|---|---|


##### Commented Code exist

###### There are some instances of code being commented out in the following files that should be removed:


Line Comment

61 // assert(a == b * c + a % b); // There is no case in which this doesn't hold

###### Recommendation
 Remove the commented code, or address them properly.


##### Audit Comments

###### We recommend you to use the special form of comments (NatSpec Format, Follow link for more information https://docs.soliditylang.org/en/ v0.5.10/natspec-format.html) for your contracts to provide rich documentation for functions, return variables and more. This helps investors to make clear what that variables, functions etc. do.

 31. January 2022:

 • Read whole report for more information


25

|Line|Comment|
|---|---|
|61|// assert(a == b * c + a % b); // There is no case in which this doesn't hold|


int256 _magCorrection =
magnifiedDividendPerShare.
mul(value).toInt256Safe();

magnifiedDividendCorrectio
ns[from] =
magnifiedDividendCorrectio
ns[from].add(_magCorrectio
n);

magnifiedDividendCorrectio
ns[to] =
magnifiedDividendCorrectio
ns[to].sub(_magCorrection);
}

