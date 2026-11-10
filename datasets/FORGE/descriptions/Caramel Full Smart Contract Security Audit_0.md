### High Severity Issues

###### 1. Wrong transferFrom

Issue:

It is possible to call transferFrom with more tokens than allowed if the
sender and recipient are not owner.

For example Alice allowed Bob to transfer 98 tokens. Bob will call the
transferFrom for 100 tokens (which is more than the allowed amount!). 2
percent from 100 tokens will be burnt and then 98 tokens will be
transferred and approved also 98 tokens which is allowed by Alice.

But Alice will lose 100 tokens in total instead of allowed 98.

Recommendation:

Call the approve before the burning and transfering.

