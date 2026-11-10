## QSP-1 Inaccurate token prices

#### Severity: High Risk

 Status: Fixed

###### File(s) affected: RariFundManager.sol

 Description: The getRawFundBalance() function should return the total balance of all RFT holders’ funds and all unclaimed fees of all currencies, in USD. However, the computation on L503 assumes that all currencies are worth 1 USD. This has significant impact on the entire system, including accrued interest, fees, deposits and withdrawals.

 Exploit Scenario: We assume a malicious user called Mallory does the following steps:

#### 1. Mallory deposits a large amount M of a token that is worth P1 less than 1 USD.

 2. Mallory then withdraws an amount M of another token that is worth P2 more than 1 USD.

 3. Mallory profits M*(P2-P1) from the price difference between the withdrawn and the deposited tokens.

###### For example if (P2-P1) is USD 1 cent and M is 1 million, then the attacker makes a profit of 10K USD from a single iteration of the exploit described above. However, an attacker can perform this attack several times to drain all funds. This is especially likely to happen with flash loans where any users can take out a large amount M and perform the exploit described above.

 Recommendation: Do not assume that all currencies are equal to 1 USD. Use secure and reliable price oracles to get the exact currency price.


-----

