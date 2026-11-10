#### MWR - Multisig Wallet Requirements

**Criticality** Medium

**Location** contracts/WorldToken.sol#L397,432

**Status** Unresolved

#### Description

The implementation of the multisig wallet functionality in the contract has a severe flaw that

compromises its intended security. Currently, the `numConfirmationsRequired`

variable can be modified through the multisig wallet functionality, which sets the minimum

number of confirmations needed for executing admin functions. The required confirmations

can be set to a minimum of 1, effectively bypassing the whole purpose of having a multisig

mechanism. Additionally, the `numConfirmationsRequired` variable is initialized to 1.

As a result of this vulnerability, the multisig wallet fails to provide the expected security

benefits. Any authorized owner could potentially call admin functions without needing

sufficient approvals from other owners, rendering the concept of multiple authorizations

meaningless.


-----

#### Recommendation

The team is advised to take these segments into consideration and rewrite them so that the

contract provides the expected security benefits. A recommended approach would be to

either modify the `numConfirmationsRequired` to be a constant variable and greater

or equal than 2, or modify the `require(_required > 0 && _required <=`

`owners.length, "MultisigWallet: invalid requirement");` code segment

so that the `_required` variable is at least 2.

This significantly enhances the security of the multisig wallet mechanism by enforcing a

reasonable minimum number of confirmations for executing admin functions. It also

prevents the multisig wallet from being compromised by a single authorized owner and

ensures that critical actions require a collaborative effort from multiple authorized parties.


-----

