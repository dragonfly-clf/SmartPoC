#### High severity issues

###### 1. Tax is applied when more than 0.01% of the total supply is sent

 Line Code

 1325 function disruptiveTransfer(address recipient, uint256 amount) public payable returns (bool) {     _transfer(_msgSender(), recipient, amount, msg.value);     return true;   }

 Description: According to HT Reward Pool agreements on moonship.finance, with respect to the Anti Pump-Dump-Exit Whales.

 04


-----

###### Transactions (sell/buy/transfer) that trade more than 0.01% of the total supply will be rejected. If whales don't want to be taxed 10% to make a transfer (between 2 wallets) that is larger than 0.01% of the total supply, they can use the Disruptive Transfer feature: the transfer will be charged for 2 HT without being taxed 10%.
 This statement was tested and failed during the functional test. As a result, 10% of the tax was applied for the receiver when the sender sent more than 0.01% of the total of the supply along with 2 ETH.
 POC: 1. The sender sent more than 0.01% of the total supply, which is 10e30 MSP (the sender is not an owner and 10e30 MSP = 0.1% of the total supply). 2. The receiver received less than 10e30 MSP (~90% of 10e30 MSP).
 Expected result: The receiver should have received the same amount of MSP sent by the sender without being taxed.
 Remediation: Please consider rewriting this function and add the sender to _isExcludedFromFee when the amount is > 0.01 of the total supply and msg.value is called.

 Status: Closed The team confirmed that 10% of the tax is still applied whenever the Disruptive Transfer feature is called by the Whales.

 05


-----

|Line|Code|
|---|---|
|995|function transfer(address recipient, uint256 amount) public override returns (bool) { _transfer(_msgSender(), recipient, amount, 0); return true; }|
|1009 function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) { _transfer(sender, recipient, amount, 0); _approve(sender, _msgSender(), _allowances[sender] [_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance")); return true; }||


