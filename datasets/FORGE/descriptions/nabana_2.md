#### DTA - Dividend Tracker Architecture

|Criticality|Minor / Informative|
|---|---|
|Location|Nabana.sol#L2260|
|Status|Unresolved|


##### Description


An ordinary DividendTracker usually performs expensive gas calls to sell tokens, get
the rewarded token and distribute it progressively to the users. The contract's
implementation does not interact with other tokens, either by swapping or
transfering. As a result, the gas cost for the NABANA business logic is much
smaller. The architectural desicion to extract it as an external contract increases
dramatically the gas fee, as all the calls being made, including the minting process,
consume gas like an external contract.


##### Recommendation


The team is advised to reconsider the business logic of using an external contract. A
recommended approach could be implementing a simpler, internal solution, which
would cost less gas and be less complicated.


-----

