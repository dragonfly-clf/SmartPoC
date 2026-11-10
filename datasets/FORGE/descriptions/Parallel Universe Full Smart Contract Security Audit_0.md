### High Severity Issues

###### 1. Wrong burn and mint

Issue:

In burn and mint functions there are wrong values adding because of not
converting _value. _rOwner and _tTotal show balances in different modes
and same values will be added / subtracted to them, which will make it
wrong.

Recommendation:

Please check if the addresses are included in reward or not and add the
values correctly by multiplying by the rate.

