Critical-Risk

1. The contract contains maximum transaction without limit, this is will bring an issue

when the user tries to sell and the max transaction is 0 (Zero). This function can
cause the transaction to stop.

// Set the maximum transaction limit

function setTxLimit(uint256 amountBuy) external onlyOwner {

_maxTxAmount = amountBuy;
}

2. Owner can stop trading status and can sell the tokens owned even in the stop trading

status, this is a honeypot indication.

function tradingstatus(bool state) public onlyOwner {

tradingOpen = state;
}

3. Owner can set fee without limit and this is honeypot indication.

function setFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _ecosystemFee,
uint256 _feeDenominator) external onlyOwner {

liquidityFee = _liquidityFee;
marketingFee = _marketingFee;
ecosystemFee = _ecosystemFee;
totalFee = _liquidityFee.add(_marketingFee).add(_ecosystemFee);
feeDenominator = _feeDenominator;
}

#### 