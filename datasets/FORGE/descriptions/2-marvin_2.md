#### BC - Blacklists Addresses

**Criticality** Critical

**Location** MarvinInu.sol#L1011,1117

**Status** Unresolved

#### Description

The contract owner has the authority to stop addresses from transactions. The owner may

take advantage of it by calling the `addSnipers` function.
```
   function addSnipers(address[] calldata accounts) external
 onlyOwner {
      uint256 len = accounts.length;
      for(uint256 i = 0; i < len;) {
        _sniper[accounts[i]] = true;
        unchecked {
          i++;
        }
      }
   }
 function _transfer(
      address from,
      address to,
      uint256 amount
   ) internal override {
      require(!_sniper[from], "Sniper rejected");
      ...
   }

#### Recommendation

```
The team should carefully manage the private keys of the owner’s account. We strongly

recommend a powerful security mechanism that will prevent a single user from accessing

the contract admin functions. Some suggestions are:

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a multi-sign wallet so that many addresses will confirm the action.


-----

- Introduce a governance model where users will vote about the actions.

- Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

