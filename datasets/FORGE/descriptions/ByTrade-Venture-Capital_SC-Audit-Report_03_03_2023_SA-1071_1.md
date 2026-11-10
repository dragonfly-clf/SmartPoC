H02. Insufficient Balance
   The contract operates with some initialBalance value which is
   considered as some initial value that should be available on the
   contract. Availability of this balance is not guaranteed by the
   contract code.
   Users' balances can be used for paying rewards that can lead to the
   inability to withdraw funds from the contract.
   Path: ./contracts/Bytrade_Staking.sol : stake(uint,uint)
   Recommendation: Ensure that the initialBalance is really available on
   the contract before allowing to stake.
   Found in: 00cc24ea2bdbe16a77237b64b9f6b35da0acae00
   Status: Fixed (Revised commit:
   a686c324db38d378b45fe758a3a7ad83e8341473)
  Medium
 