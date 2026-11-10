7. Conformance to Solidity naming conventions
Solidity defines a naming convention that should be followed.
Rule exceptions:
● Allow constant variable name/symbol/decimals to be lowercase
(ERC20).
● Allow _ at the beginning of the mixed_case match for private
variables and unused parameters.
Contracts: Colexion
Functions: t_transfer, create_Auction, end_auction, 
Struct: Auction_data
Variables: T_In_Auction, T_Auction, token_bidders, bidder_list,
T_cost
Modifiers: in_auction, auction_ended, only_owner, only_bidders,
not_auction_winner
Recommendation: Follow the Solidity naming convention.
Status: Fixed
