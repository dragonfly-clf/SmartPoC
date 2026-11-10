H01. Funds Lock
   Function stake(uint,uint) is an external payable function. This means
   that the contract can accept native coins to its account, but does
   not have any withdrawal mechanisms. It is an inefficient use of Gas
   and does not match the technical and functional requirements.
   Path: ./contracts/Bytrade_Staking.sol : stake(uint,uint)
   Recommendation: Forbid the contract to accept native coins or provide
   mechanisms of withdrawal.
   Found in: 00cc24ea2bdbe16a77237b64b9f6b35da0acae00
   Status: Fixed (Revised commit:
   a686c324db38d378b45fe758a3a7ad83e8341473)
 