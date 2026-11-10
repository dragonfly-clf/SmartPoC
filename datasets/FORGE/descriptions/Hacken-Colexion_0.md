1. Reentrancy
   There is a possibility to re-enter the function for the message sender.
   If the transaction would be created from the contract which does have
   a fallback function it will be able to reenter the function again and
   again, until not drain all balance of the Colexion contract
   Contracts: Colexion
   Functions: withdraw, end_auction
   Recommendation: Please update the balance to zero before doing the
   transfer.
   Status: Fixed
   