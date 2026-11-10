#### CR - Code Repetition

**Criticality** minor

**Location** contract.sol#L1873,1903

##### Description

The bidirectional logic of sending funds either in native currency or token is
repetitive in the source code. Those segments increase the code size of the
contract unnecessarily.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1873,1903|

```
if (!walletCharityFeeInBNB) {
  uint256 currentBalance = balanceOf(feeWalletCharity);
  _tokenTransferNoFee(
    address(this),
    feeWalletCharity,
    spentAmount
  );
  setBalance(
    payable(feeWalletCharity),
    balanceOf(feeWalletCharity),
    currentBalance
  );
} else {
  uint256 initialBalance = address(this).balance;
  // swap tokens for ETH
  swapTokensForBNB(spentAmount);
  // how much ETH did we just swap into?
  uint256 newBalance = address(this).balance.sub(initialBalance);
  transferEth(feeWalletCharity, newBalance);
}

```

##### Recommendation

Create an internal function that contains the code segment and remove it from all
the sections.


-----

