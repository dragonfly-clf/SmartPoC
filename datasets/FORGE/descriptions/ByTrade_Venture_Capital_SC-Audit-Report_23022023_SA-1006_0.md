H01. Requirements Violation
   In the functional documentation of the project, the contract
   ByTradeToken is said to meet the ERC20 standard. However, the code
   refers to the BEP20 standard instead, which follows a different
   standard.
   The code should not violate requirements provided by the Customer
   since it can lead to misinformation for users, as well as lack of
   transparency and their derived issues.
   Paths:
   ./contracts/ByTradeToken
   ./contracts/BEP20
   ./contracts/IBEP20
   Recommendation: The code should meet the functional requirements.
   Status: Fixed (Revised commit: 510e568)
 