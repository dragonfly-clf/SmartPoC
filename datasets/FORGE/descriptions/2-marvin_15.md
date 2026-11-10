#### L08 - Tautology or Contradiction

**Criticality** Minor / Informative

**Location** MarvinInu.sol#L1304

**Status** Unresolved

#### Description

A tautology is a logical statement that is always true, regardless of the values of its

variables. A contradiction is a logical statement that is always false, regardless of the values

of its variables.

Using tautologies or contradictions can lead to unintended behavior and can make the code

harder to understand and maintain. It is generally considered good practice to avoid

tautologies and contradictions in the code.
```
 require(_percent <= 1000 && _percent >= 0, "Must set auto LP
 burn percent between 0% and 10%")

#### Recommendation

```
The team is advised to carefully consider the logical conditions is using in the code and

ensure that it is well-defined and make sense in the context of the smart contract.


-----

