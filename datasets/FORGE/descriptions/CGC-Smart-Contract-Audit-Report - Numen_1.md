##### 3.2 TOKEN LOCKUP INFORMATION

ID: NVE-002                         Location:CarGaiaToken.sol

Severity: Informational                 Category: Business Issues

Likelihood: Informational

Impact: Informational

**Description:**

As shown in Figure 4 below, the total amount of CGC tokens is 1 billion, which 16.75%

are allocated directly, and the remaining 83.25% are locked.

The lock information is as follows:

**Lock Address** **Percent** **Unlock Info**

After one year, 20% of
the locked total amount

sale(0x875f474417E6f2d393B57E032a0c439 will be released directly,
18%
7a207C6d6) and remaining 80%

daily unlock for 48
months.

community(0x46D83a3e67140F1B080B713d weekly unlock for 24
11.4%
a78d884c2076faB8) months

advisor(0xA26632155fCCA6E855D0364D48
5% yearly unlock for 5 years
E36C59EF04A706)

Confidential 10

|Lock Address|Percent|Unlock Info|
|---|---|---|
|sale(0x875f474417E6f2d393B57E032a0c439 7a207C6d6)|18%|After one year, 20% of the locked total amount will be released directly, and remaining 80% daily unlock for 48 months.|
|community(0x46D83a3e67140F1B080B713d a78d884c2076faB8)|11.4%|weekly unlock for 24 months|
|advisor(0xA26632155fCCA6E855D0364D48 E36C59EF04A706)|5%|yearly unlock for 5 years|


-----

|ecosystem(0xE55d2a665970cEB46a716084 6729Aa62119CD919)|19.6%|daily vesting for 24 months|
|---|---|---|
|foundation(0x24aD61058d4243535FeC9136 6283192fBB1Fb9Bc)|14.25%|weekly unlock for 24 months|
|team(0x09B34152e7cB2Ec41D35B7FB240b 307E445D2bCf)|15%|yearly unlock for 5 years|


_Figure 4 initBalances function_


**Recommendations:**


Confidential 11


-----

Null

**Result: Pass**

