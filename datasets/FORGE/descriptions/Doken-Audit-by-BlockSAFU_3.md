#### WRITE CONTRACT

 1. addToBlacklist - High Risk addresses (address[]) (Function for blacklist address - onlyOwner)

 2. pauseTx - High Risk _buy (bool) _sell (bool) (Function for pause trade, buy or sell, fill with true or false)

 3. setBuyTxMaximum max (uint256) (Function for set buy tx amount - can’t set below 0.7% from total supply)

 4. setSellTxMaximum max (uint256) (Function for set sell tx amount - can’t set below 0.7% from total supply)

 5. renounceOwnership (Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner)

 6. transferOwnership newOwner (address) (Its function is to change the owner)