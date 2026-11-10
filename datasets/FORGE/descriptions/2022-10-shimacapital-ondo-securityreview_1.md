2. Risk of accounting errors due to missing check in the invest function|Col2|
|---|---|
|Severity: High|Difcfiulty: Medium|
|Type: Data Validation|Finding ID: TOB-ONDO-2|
|Target: contracts/Treasury.sol||


##### Description
Because of a missing check in the invest function, investing multiple tokens with different
decimals in the same strategy will result in incorrect profit-and-loss (PnL) reporting, which
could result in the loss of user or protocol funds.

The invest function is responsible for transferring funds from the treasury to a strategy
and for updating the strategy’s investment balance (i.e., strategyInvestedAmount).
However, the invest function accepts any token in the collateral array alongside the
token amounts to be transferred. Therefore, if multiple tokens with different decimals are
used to invest in the same strategy, the treasury’s investment records would not accurately
reflect the true balance of the strategy, resulting in accounting errors within the protocol.
```
 694 function invest(
 695 address strategy,
 696 uint256 collateralAmount,
 697 uint256 collateralIndex
 698  ) external whenNotPaused whenTreasuryActive onlyFundManager {
 699 IERC20 collateralToken = collateral[collateralIndex].collateralToken;
 700 require(
 701 address(collateralToken) != address(0),
 702 "Treasury: Cannot used a removed collateral token"
 703 );
 704 // Require that the strategy address is approved
 705 require(
 706 hasRole(strategy, Roles.STRATEGY_CONTRACT),
 707 "Treasury: Must send funds to approved strategy contract"
 708 );
 709
 710 // Scale up invested amount
 711 investedAmount += _scaleUp(collateralAmount, collateralIndex);
 712
 713 // Account for investment in strategyInvestedAmounts
 714 strategyInvestedAmounts[strategy] += collateralAmount;
 715
 716 // Transfer collateral to strategy
 717 collateralToken.safeTransfer(strategy, collateralAmount);

```
_[Figure 2.1: The invest function in Treasury.sol#L694–719](https://github.com/ondoprotocol/monopoly/blob/814cfcfa04a7bfa4ae3fa395cafa329767dc67ec/contracts/Treasury.sol#L694-L719)_

Trail of Bits 25 Ondo Finance Security Assessment


-----

##### Exploit Scenario
The CompoundStrategy contract is supposed to accept only USDC as its investment token.
However, the fund manager, Bob, triggers investments into the Compound strategy using
FRAX tokens instead. Due to insufficient validation of the collateralToken value, the
transaction succeeds, causing a mismatch between the treasury’s account and the total
value of assets in the strategy.

##### Recommendations
Short term, implement a check within the invest function to ensure that the
```
collateralToken address of the supplied collateralIndex value matches the token

```
accepted by the strategy.

Long term, carefully review token usage across all contracts to ensure that each token’s
decimal places are taken into consideration.

Trail of Bits 26 Ondo Finance Security Assessment


-----

|