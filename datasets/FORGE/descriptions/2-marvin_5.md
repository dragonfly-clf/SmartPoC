#### TUU - Time Units Usage

**Criticality** Minor / Informative

**Location** MarvinInu.sol#L1303

**Status** Unresolved

#### Description

The contract is using arbitrary numbers to form time-related values. As a result, it decreases

the readability of the codebase and prevents the compiler to optimize the source code.
```
 require(_frequencyInSeconds >= 600, "cannot set buyback more
 often than every 10 minutes");

#### Recommendation

```
It is a good practice to use the time units reserved keywords like `seconds,` `minutes,`

`hours,` `days` and `weeks` to process time-related calculations.

It's important to note that these time units are simply a shorthand notation for representing

time in seconds, and do not have any effect on the actual passage of time or the execution

of the contract. The time units are simply a convenience for expressing time in a more

human-readable form.


-----

