##### Medium severity issues

**1.** **Loops are extremely costly**
Line no -716, 797, 1251
**Description:**
The FortuneCookie V2 contract has some for loops in the contract that include state
variables like .length of a non-memory array, in the condition of the for loops.

As a result, these state variables consume a lot more extra gas for every iteration of the
for loop.
The following function includes such loops at the above-mentioned lines:

**●** **includeInReward**

**●** **_getCurrentSupply**

**●** **airDrop**

**Recommendation:**
It's quite effective to use a local variable instead of a state variable like .length in a loop.
This will be a significant step in optimizing gas usage.
For instance,
local_variable = _recipients.length

for (uint256 index = 0; index < local_variable; index++) {

if (!airdropReceived[_recipients[index]]) {

airdropReceived[_recipients[index]] = true;

This audit does not provide a security or correctness guarantee of the audited smart contract. Securing smart contracts is a
multistep process, therefore running a bug bounty program as a complement to this audit is strongly recommended.


-----

transfer(_recipients[index], _amounts[index]);
airdropped = airdropped.add(_amounts[index]);
}
}

**Acknowledged(June 4th 2021): Fortune Cookie team has acknowledged the issue.**

This is an intentional functionality by the dev team.

**Explanation by the team:**

_“The loop is to allow us to migrate holders from our previous iteration of the token over to_
_this contract. We paid the price for the loop in gas as we knew the number of addresses_
_to send to. Moreover, this function can never be called again since we renounced the_
_ownership.”_

**2.** **No Input Validations performed on insertUser function**
Line no - 586
**Description:**
The insertUser function initializes the userData struct with crucial information like
address, index as well as win counts.

However, no input validation is performed on any of the arguments passed to this
function. This will lead to a situation where zero addresses can be passed as user’s
address as well as any uint value can be passed for the totalWon or lastWon elements
of the userStruct of the user being added in the contract.

**Recommendation:**
Including input validation checks ensures that no invalid arguments are passed while
calling the function.

**Acknowledged(June 4th 2021): Fortune Cookie team has acknowledged the issue.**

This is an intentional functionality by the dev team.

**Explanation by the team:**

_“There’s nothing wrong with the 0 address being part of the lottery. Also note that_
_because of _transfer, 0 address can never be a recipient.”_

This audit does not provide a security or correctness guarantee of the audited smart contract. Securing smart contracts is a
multistep process, therefore running a bug bounty program as a complement to this audit is strongly recommended.


-----

**3.** **The _handleLottery function includes redundant IF Statement condition**
Line no - 1198
**Description:**
The following IF statement in the handleLottery function includes a redundant
conditional check with the _balanceWinner local variable.

It ensures that the balanceWinner variable must be greater than zero and greater the
minBalance.
However, the “_balanceWinner >= 0” validation is not necessary as it will automatically
be ensured if the balanceWinner is greater than the _minBalance local variable.

**Recommendation:**
If the above mentioned scenario is not intended, it is recommended to modify the IF
statements accordingly.

**Acknowledged(June 4th 2021): Fortune Cookie team has acknowledged the issue.**

This is an intentional functionality by the dev team.

**Explanation by the team:**

_“The if statement was structured that way to make the logic more readable. The_
_performance impact should be negligible.”_

