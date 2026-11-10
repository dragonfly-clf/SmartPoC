High severity issues

 1. Loss of tokens forever

 In the transfer and transferFrom functions there is no check for a zero address. If a user transfers his/her tokens to a zero address they will be lost forever and there is no way of retrieving them.
 Suggestion: Please add a check in both the functions to check whether the to address entered is a zero address or not, something like this => require(to != address(0), “Invalid address”);

 Status: Acknowledged Client’s Comment: Our products are in charge of controlling and managing it. This is done so that our token is not handled if it is used outside of the Our ecosystem. If this is utilized within our ecosystem, it is maintained through our wallet.  We want people to download our wallet and use it,.people can't send our tokens to metamask etc but that's where we don't control and we clearly state if it's lost its lost, hence people have to download and use our wallet

 