### Low Severity Issues

###### 1. Out of gas

Issue:

❏ The function includeInReward() uses the loop to find and remove

addresses from the _excluded list. Function will be aborted with
OUT_OF_GAS exception if there will be a long excluded addresses list.