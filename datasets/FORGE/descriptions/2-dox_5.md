#### IFV - Inconsistent Fee Visibility

**Criticality** Minor / Informative

**Location** contracts/Twelve_Days_Of_Xmas.sol#L154

**Status** Unresolved

#### Description

The contract is utilizing the `marketingFee` and `otherFee` variables to calculate
```
totalFee, which represents the fee within the contract. However, there is an

```
inconsistency in the visibility of these fee variables. The `marketingFee` is declared as

`public, making it visible and accessible externally, while` `otherFee` is declared as
```
private, restricting its visibility to within the contract only. This discrepancy in visibility

```
leads to a lack of transparency, as external entities or users can view only one component

of the total fee structure ( marketingFee ), but not the other ( otherFee ). Such

inconsistency can cause confusion and hinder the ability of users to fully understand the fee

dynamics of the contract.
```
  uint256 public marketingFee = 2;
  uint256 private otherFee = 2;

#### Recommendation

```
It is recommended to use consistent visibility for all fee-related variables within the contract.

If the intention is to maintain transparency and allow users to view the complete fee

structure, both `marketingFee` and `otherFee` should be declared as `public .`

Conversely, if the intention is to keep fee details private, then both should be declared as
```
private . Aligning the visibility of these variables will ensure clarity and consistency in

```
how fee information is presented to users and external entities, enhancing the contract's

transparency and trustworthiness.


-----

