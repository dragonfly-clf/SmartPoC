#### LTW - Liquidity to Team Wallet

**Criticality** high

**Location** https://bscscan.com/address/0xcb9fd3784e9f369c4ad3bd4cb0d3a21acbf23a51#c
ode#L1616

##### Description

The contract owner has the authority to transfer funds to the team wallet. These
funds have been swapped from the swap & liquify feature. The owner may take
advantage of it by setting a high fee to the marketingFee variable.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0xcb9fd3784e9f369c4ad3bd4cb0d3a21acbf23a51#c ode#L1616|


// dev Portion

uint256 devBalance = newBalance.div(totalLiqFee).mul(_devFee);
uint256 devPortion = otherHalf.div(totalLiqFee).mul(_devFee);

uint256 finalBalance = newBalance.sub(devBalance);
uint256 finalHalf = otherHalf.sub(devPortion);

```
(bool sent,) = _devAddress.call{value: devBalance}("");
    if (sent) {
      _tokenTransfer(address(this), _devAddress, devPortion, false);
    } else {
      addLiquidity(devPortion, devBalance, _devAddress);
    }

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

