2. No way to put a token on “not for sale”
  Regarding the documentation it says:
  - The creator or owner of the token can place it on buy, auction
  or not on sale. 
  - When the user buy the NFT it is by default on not for sale
  But in the code there is no way to put the item on “not for sale”. Even
  more, there is no way to disallow to directly buy the item while it’s
  on auction. 
  So, each token could be bought no matter if the owner/creator wants
  not to sell or even wants to make an auction.
  Contracts: Colexion
  Function: purchaseToken
  Recommendation: Please make sure that the token could be “not for sale”
  or “auction only”.
  Status: Fixed
  Medium
  No medium severity issues were found.
 Low
  