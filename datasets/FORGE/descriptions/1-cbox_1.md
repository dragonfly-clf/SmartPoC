#### ELFM - Exceed Limit Fees Manipulation

**Criticality** minor

**Location** contract.sol#L471,481,491,501

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling one of the fee setter functions with 3000.

|Criticality|minor|
|---|---|
|Location|contract.sol#L471,481,491,501|

```
function setDevelopmentFee(uint256 buy, uint256 sell, uint256 p2p) external
onlyOwner {
    require(marketingFee[0].add(liquidityFee[0]).add(rewardsFee[0]).add(buy)
<= 3000, "Max fee limit reached for 'BUY'");
    require(marketingFee[1].add(liquidityFee[1]).add(rewardsFee[1]).add(sell)
<= 3000, "Max fee limit reached for 'SELL'");
    require(marketingFee[2].add(liquidityFee[2]).add(rewardsFee[2]).add(p2p)
<= 3000, "Max fee limit reached for 'P2P'");
    developmentFee[0] = buy;
    developmentFee[1] = sell;
    developmentFee[2] = p2p;
}

```

##### Recommendation

The contract could embody a check for 25% maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

