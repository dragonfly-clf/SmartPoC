Unchecked Array Lenght (1 item)

##### Function Severity Remedation
Ethereum is a very
resource-constrained
environment. Prices per
                    Either explicitly or just due
computational step are
orders of magnitude higher Severity to normal operation, the
                   : High number of iterations in a loop
than with centralized
                    can grow beyond the block gas
providers. Moreover,
                    limit, which can cause the
Ethereum miners impose a
                    complete contract to be
limit on the total number
                    stalled at a certain point.
of Gas consumed in a
                    Therefore, loops with a bigger
block. If array.length is
                    or unknown number of steps
large enough, the function
                    should always be avoided.
exceeds the block gas
limit, and transactions
calling it will never be
confirmed.
for (uint256 i = 0; i <
array.length ; i++) {
cosltyFunc(); }
This becomes a security
issue if an external actor
influences array.length.
E.g., if an array
enumerates all registered
addresses, an adversary
can register many
addresses, causing the
problem described above.

```
|Function|Severity|Remedation|
|---|---|---|
|Ethereum is a very resource-constrained environment. Prices per computational step are orders of magnitude higher than with centralized providers. Moreover, Ethereum miners impose a limit on the total number of Gas consumed in a block. If array.length is large enough, the function exceeds the block gas limit, and transactions calling it will never be confirmed. for (uint256 i = 0; i < array.length ; i++) { cosltyFunc(); } This becomes a security issue if an external actor influences array.length. E.g., if an array enumerates all registered addresses, an adversary can register many addresses, causing the problem described above.|Severity : High|Either explicitly or just due to normal operation, the number of iterations in a loop can grow beyond the block gas limit, which can cause the complete contract to be stalled at a certain point. Therefore, loops with a bigger or unknown number of steps should always be avoided.|


-----

```
