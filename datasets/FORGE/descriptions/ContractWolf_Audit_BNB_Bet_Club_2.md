##### Max transaction amount and wallet amount can be set to zero can be used to pause transactions

###### Owner can update max transaction amount and max wallet amount with an indefinite amount

```
function setMaxTx(uint256 maxTx) external onlyOwner {
  _maxTxAmount = maxTx * 10**9;
}
function setMaxPerWallet(uint256 maxPerWallet) external onlyOwner {
  MAX_PER_WALLET = maxPerWallet * 10**9;
}

```

**Suggestion**

###### Adding validation checks to the maxTransactionAmount and maxWallet parameters to ensure they are not equal to zero and are greater than zero can prevent unintended behavior or error.

```
function setMaxPerWallet(uint256 maxPerWallet) external onlyOwner {
 MAX_PER_WALLET = maxPerWallet * 10**9;

```
**Suggestion**

###### Adding validation checks to the maxTransactionAmount and maxWallet parameters to ensure they are not equal to zero and are greater than zero can prevent unintended behavior or error.