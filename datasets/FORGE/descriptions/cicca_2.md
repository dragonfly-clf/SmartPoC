#### IFM - Inconsistent Fee Mechanism


#### Description


The contract calculates a `stakingAmt` variable, which represents a percentage of the


transferred amount. This percentage is deducted from the original amount, and the tax is


then applied to the remaining amount. As a result, the fees are not calculated proportionally.


Instead, a percentage amount is taken as fees, and an additional tax amount is applied to

the remaining amount. This approach can lead to unintended consequences and may not


align with the expected behavior of a standard tax fee system.


-----

#### Recommendation


It is recommended to adopt a percentage-wise method for calculating the tax fees. Given


that the intended functionality is to compute a tax fee, the contract could implement a


standard percentage tax fee. This ensures that the tax is applied uniformly to the entire


amount, providing clarity and predictability to the users of the contract.


-----

