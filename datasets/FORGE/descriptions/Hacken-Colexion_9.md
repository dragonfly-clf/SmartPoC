6. “bidders” field is updated but never used
While there is an array in the structure “Auction_data” that is always
updated in the case of the bidder didn’t hit the maximum bid, but it
is never used in the code, it’s just burning the gas while doing
nothing.
Contracts: Colexion
Function: bid (lines: 557)
Recommendation: Please remove the “bidders” field from the structure.
Status: Fixed
