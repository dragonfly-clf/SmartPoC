1. Tax is applied when more than 0.01% of the total supply is sent

 Line Code

 1393 function disruptiveTransfer(address recipient, uint256 amount) public payable returns (bool) {     _transfer(_msgSender(), recipient, amount, msg.value);     return true;   }

 Description According to Anti Pump-Dump-Exit Whales agreements on the garfield.finance, transactions (sell/buy/transfer) that trade more than 0.01% of the total supply will be rejected. If whales want to make a transfer (between 2 wallets) that is larger than 0.01% of the total supply, they can use the Disruptive Transfer feature: the transfer will be charged for 2 BNB (taxed 10%).

 This statement was tested and failed during the functional test. As a result, 10% of the tax was applied for the receiver when the sender sent more than 0.01% of the total of the supply along with 2 BNB.

 POC 1. The sender sent more than 0.01% of the total supply, which is 2e17 GAR (the sender is not an owner and 2e17 GAR = 0.02% of the total supply). 2. The receiver received less than 2e17 GAR (~90% of 2e17 GAR).

 Expected result The receiver should have received the same amount of GAR sent by the sender without being taxed.

 Remediation Please consider rewriting this function and adding the sender to _isExcludedFromFee when the amount is > 0.01 of the total supply and msg.value is called.

 05


-----

###### Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit 9940d96cc1528698533cd2e7db9de2bc4689bffc

 