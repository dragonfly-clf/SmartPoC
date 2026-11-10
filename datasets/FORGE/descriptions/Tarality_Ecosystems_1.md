I01. Public Functions That Should Be External
   Functions that are only called from outside the contract should be
   defined as external. External functions are much more Gas efficient
   compared to public functions.
   Path: Token.sol : mint()
   Recommendation: Make these functions external.
   Status: Reported
                www.hacken.io

```
|Impact|Medium|
|---|---|
|Likelihood|High|


-----

```
