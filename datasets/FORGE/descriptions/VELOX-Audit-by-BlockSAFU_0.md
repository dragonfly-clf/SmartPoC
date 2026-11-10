#### MANUAL CODE REVIEW

 Minor-risk

 4 minor-risk code issues found

Weak PRNG (Pseudo-random number generator), do not use blocktimestamp as
source randomness as this can be manipulated by miners.
Recommendation: Avoid relying on block.timestamp

function unlock() public virtual {
require(_previousOwner == msg.sender, "You don't have permission to unlock.");
require(block.timestamp > _lockTime , "Contract is locked.");
emit OwnershipTransferred(_owner, _previousOwner);
_owner = _previousOwner;
}

The return value of an external transfer/transfer from the return value is checked.
Recommendation: use SafeERC20, or ensure that the transfer/transfers from return
value are checked

function transferFrom(address sender, address recipient, uint256 amount) public override
returns (bool) {
_transfer(sender, recipient, amount);
_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount,
"ERC20: transfer amount exceeds allowance"));
return true;
}

Calls to a function sending ether to an arbitrary address.

**function** **setDevWalletAddress(address _addr) public** **onlyOwner {**
_devWalletAddress = _addr;
}


-----

All fees transferred to one address, it will be mixed up and will make it difficult to
trace the use of funds

**function** **_getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256,**
uint256) {
uint256 tFee = calculateTaxFee(tAmount);
uint256 tLiquidity = calculateLiquidityFee(tAmount);
uint256 tDev = calculateDevFee(tAmount);
uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity).sub(tDev);
**return (tTransferAmount, tFee, tLiquidity, tDev);**
}

####   Medium-risk

 0 medium-risk code issues found

 Should be fixed, could bring problems.


-----

