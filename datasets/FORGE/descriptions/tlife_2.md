#### MEE - Missing Events Emission

**Criticality** Minor / Informative

**Location** TLIFE_Coin.sol#L424

**Status** Unresolved

#### Description

The contract performs actions and state mutations from external methods that do not result

in the emission of events. Emitting events for significant actions is important as it allows

external parties, such as wallets or dApps, to track and monitor the activity on the contract.

Without these events, it may be difficult for external parties to accurately determine the

current state of the contract.
```
   function mint(address account, uint256 amount) external
 canMint {
      _mint(account, amount);
   }

#### Recommendation

```
It is recommended to include events in the code that are triggered each time a significant

action is taking place within the contract. These events should include relevant details such

as the user's address and the nature of the action taken. By doing so, the contract will be

more transparent and easily auditable by external parties. It will also help prevent potential

issues or disputes that may arise in the future.


-----

