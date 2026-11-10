##### 1. Calculation error

Issue:

In StrategyCompoundPantherV2 there are 3 functions - tax, _depositTo,
withdrawAll calculates tax fee in the wrong way. In all functions
transferTaxRate = 500 and after calculating it ends to 2500%.
Recommendation:

If logic is to divide tax fee for contract and pool per 5%, we recommend
to avoid multiplying and use sum.

#### Medium Severity Issues

No low severity issues found.

#### Low Severity Issues

No low severity issues found.