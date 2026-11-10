#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L573,770

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setRates function with high
percentage values.

|Criticality|critical|
|---|---|
|Location|contract.sol#L573,770|

```
 function setRates(
    uint256 taxFee,
    uint256 liquidityFee,
    uint256 lpHolderFee,
    uint256 lpPowerFee,
    uint256 fundFee,
    uint256 communityFee,
    uint256 burnFee
  ) external onlyOwner {
    require(
       taxFee ==
         (liquidityFee +
           lpHolderFee +
           lpPowerFee +
           fundFee +
           communityFee +
           burnFee),
       "params error"
    );
    _taxFee = taxFee;
    _liquidityFee = liquidityFee;
    _lpHolderFee = lpHolderFee;
    _lpPowerFee = lpPowerFee;
    _fundFee = fundFee;
    _communityFee = communityFee;
    _burnFee = burnFee;
  }
}

```

-----

The contract owner can also convert the contract into a HONEYPOT by disabling
the buyfees, and increasing the sell fee to very high value.

```
 if (
  (_buyFeeEnable && isMarketPair[sender]) ||
  (_sellFeeEnable && isMarketPair[recipient])
) {
  tax = amount.mul(_taxFee).div(100);
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|


-----

