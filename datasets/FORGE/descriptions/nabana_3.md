#### SCP - Solidity Code Principles

|Criticality|Minor / Informative|
|---|---|
|Location|Nabana.sol#L2632,L2186|
|Status|Unresolved|


##### Description


As with any programming task, it is important to keep the Solidity code as simple
and straightforward as possible. This can help avoid errors and make it easier for
others to understand and review the code.

The processInvestment, setBalance functions returns an integer based on
some conditions, which makes it unclear of what the function's result really is.
```
 function processInvestment(address account, uint256 index, bool manual) public
 onlyOwner returns (uint8) {
  ...
  if (investment.currentInterval >= totalIntervals) {
   ...
   uint8 result = setBalance(account,
 currentInvestment.safeSub(investment.amount));
   ...
   return result;
  }
  return 1;
 }

```
Additionally, there are some code segments that could be optimized. A segment
may be optimized so that it becomes a smaller size, consumes less memory,
executes more rapidly, or performs fewer operations.

During a transaction, if the sender is an investor and the amount is smaller or equal
to the unlockedInvestments, then the contract performs the same action twice.
Once for the calculated totalFee and once for the remaining amount, which is
redundant since it can only be performed only once with the whole amount.


-----

##### Recommendation


The team is advised to follow Solidity's Code Principles in the best way possible.
Some recommendations are to use descriptive names for variables, avoid
unnecessary complexity and aim for clarity in the code. The processInvestment
and setBalance functions count return a descriptive value of what the result
actually is.

The team is advised to take into consideration code segments like double
```
decreaseUnlockedInvestments and rewrite them so the runtime will be more

```
performant. That way it will improve the efficiency and performance of the source
code and reduce the cost of executing it.


-----

