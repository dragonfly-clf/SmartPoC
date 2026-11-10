#### ELFM - Exceeds Fees Limit

**Criticality** Critical

**Location** JIMBOY.sol#L526

**Status** Renounced

#### Description

The contract owner has the authority to increase over the allowed limit of 25%. The owner

may take advantage of it by calling the `setFee` function with a high percentage value.
```
 function setFee(uint256 redisFeeOnBuy, uint256 redisFeeOnSell, uint256
 taxFeeOnBuy, uint256 taxFeeOnSell) public onlyOwner {
   _redisFeeOnBuy = redisFeeOnBuy;
   _redisFeeOnSell = redisFeeOnSell;
   _taxFeeOnBuy = taxFeeOnBuy;
   _taxFeeOnSell = taxFeeOnSell;
 }

#### Recommendation

```
The contract could embody a check for the maximum acceptable value. The team should

carefully manage the private keys of the owner’s account. We strongly recommend a

powerful security mechanism that will prevent a single user from accessing the contract

admin functions. Some suggestions are:

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a multi-sign wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.

  - Renouncing the ownership will eliminate the threats but it is non-reversible.


#### Team Update


The contract's ownership has been renounced. The information regarding the transaction


can be accessed through the following link:


[https://bscscan.com/tx/0xcc7516a17d7f5b99367b4a675a8666a3279a63133fd82c54b40a8](https://bscscan.com/tx/0xcc7516a17d7f5b99367b4a675a8666a3279a63133fd82c54b40a82d0ac33fb2d)


[2d0ac33fb2d.](https://bscscan.com/tx/0xcc7516a17d7f5b99367b4a675a8666a3279a63133fd82c54b40a82d0ac33fb2d)


-----

