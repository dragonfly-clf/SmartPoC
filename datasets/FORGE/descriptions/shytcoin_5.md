#### L02 - State Variables could be Declared Constant

**Criticality** Minor / Informative

**Location** SHYTCOIN.sol#L167,170,172,173

**Status** Unresolved

#### Description

State variables can be declared as constant using the constant keyword. This means that

the value of the state variable cannot be changed after it has been set. Additionally, the

constant variables decrease gas consumption of the corresponding transaction.
```
 kensAtAmount = 10000000000;
   address publi
 ddress public marketingWallet = 0x701A4f34A4d06
 E0DAd68CAF2dcB2b8e;
   string private constant _name = "ShytCoin";
 tring private constant _symbol = "SHYTCOIN";
   struct BuyTaxes {

#### Recommendation

```
Constant state variables can be useful when the contract wants to ensure that the value of a

state variable cannot be changed by any function in the contract. This can be useful for

storing values that are important to the contract's behavior, such as the contract's address

or the maximum number of times a certain function can be called. The team is advised to

add the constant keyword to state variables that never change.


-----

