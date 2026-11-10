Medium-risk

 2 medium-risk code issues found

 Should be fixed, could bring problems.

1. Owner can set calm down trading without no limit time

**Risk scenario: owner can set 100 years or more.**

**Recommendation: remove this function or set limit**
```
      function Launch_Settings_02__Set_Launch_Limits(
           uint256 Launch_Buy_Delay_Seconds,
           uint256 Launch_Transaction_Limit_TOKENS,
           uint256 Launch_Phase_Length_Minutes
           ) external onlyOwner {
           max_Tran_Launch = Launch_Transaction_Limit_TOKENS * 10 **
      _decimals;
           Launch_Buy_Delay = Launch_Buy_Delay_Seconds;

```

-----

```
           Launch_Length  = Launch_Phase_Length_Minutes * 60;
         }

```
2. Code has math error

**Risk scenario: holder calculation has a mathematical error. The total written supply is**
7,000,000 while the sum of the total holders is 6,999,999.94

**Recommendation: in the calculation precede multiplication before division and use**
the denominator to make calculations more accurate. not too bad of an issue
considering the math error is decreasing.


-----

#### 