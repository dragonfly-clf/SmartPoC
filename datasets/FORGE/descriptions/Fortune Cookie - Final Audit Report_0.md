##### High severity issues

**1.** **_handleLottery function includes a similar operation twice in its function body**
Line - 1159 - 1242
**Description:**
As per the current design of the _handleLottery function, it includes a call to the
**insertUser function to add the user details in the contract. It then increments the state**
variable _txCounter with 1.

However, an exact similar operation is being performed at the end of the function as
well.(Line 1235-1239).

While the call to insertUser function is being guarded by the if statements, the increment
in the _txCounter(Line 1239) is not. This might lead to an undesirable situation where
_txCounter state variable will be initialized twice.

**Recommendation:**
If the above-mentioned scenario is not intended, the _handleLottery function must be
redesigned to resolve the issue.

This audit does not provide a security or correctness guarantee of the audited smart contract. Securing smart contracts is a
multistep process, therefore running a bug bounty program as a complement to this audit is strongly recommended.


-----

**Acknowledged(June 4th 2021): Fortune Cookie team has acknowledged the issue.**

This is an intentional functionality by the dev team.

**Explanation by the team:**

_“The first of block is only triggered when the user list is empty at contract creation, or_
_when the lottery tax is 0%. After the first buy transaction after contract creation, this_
_block will never be hit as the user list will always contain at least 1 user and the pot will_
_never be 0 as there will always be at least one transaction that contributes tax to the pot._
_If the lottery tax is 0%, the return statement ensures that the lottery code is never_
_executed.”_

**2.** **insertUser function is made PUBLIC and Accessible to users**
Line no - 586-597
**Description:**
The FortuneCookie V2 contract has a very crucial function, i.e., insertUser that
initializes the userData struct and stores new users on the contract with the imperative
details about the user like address, winning counts, index etc.

However, the function has not been assigned any onlyOwner modifier and has been
marked as public, which makes it accessible to all users. It will lead to an scenario
where anyone can call this function with any arguments they want.

**Recommendation:**
If the above-mentioned scenario is not intended, it is recommended to make the
**insertUser function only accessible to the Owner of the contract.**

**Acknowledged(June 4th 2021): Fortune Cookie team has acknowledged the issue.**

This is an intentional functionality by the dev team.

This audit does not provide a security or correctness guarantee of the audited smart contract. Securing smart contracts is a
multistep process, therefore running a bug bounty program as a complement to this audit is strongly recommended.


-----

**Explanation by the team:**

_“The addUser function is intended to be public so that we can add new users manually if_
_we carry out manual giveaways. It gives us control over the user list in the event that we_
_want to add some non pre-existing users. It cannot be set to onlyOwner as we have_
_renounced ownership. It is okay for this function to be public as modifying the user list_
_will not affect the main lottery logic in any way. When a user is selected to win the lottery,_
_their balance is retrieved and compared with the minimum requirement at that point in_
_time and this balance cannot be tampered with.”_

**3.** **The function design of addWinner is inadequate**
Line no - 621-629
**Description:**
In the FortuneCookie V2 contract, the addWinner function performs a crucial task of
updating the last winner’s value as well as the address.

However, despite the fact that these are imperative state variables of the contract, the
**addWinner function is not designed effectively.**

Mentioned below are the reason behind the poor design of addWinner function:

    - The function has not been assigned an onlyOwner modifier which makes it
accessible to every user.

    - The function doesn’t involve any input validations on the arguments passed to
it.

    - It involves a redundant variable update at Line 622 as every boolean variable is,
by default, false.
Moreover, the addWinner function is being called once inside the _handleLottery
function. Therefore, if the addWinner function is only supposed to be called from within
the contract, the visibility keyword should be changed from PUBLIC to INTERNAL.

**Recommendation:**
The current function design of addWinner is not very effective. It is recommended to go
through the above-mentioned issues and update the function accordingly, unless
intended.

This audit does not provide a security or correctness guarantee of the audited smart contract. Securing smart contracts is a
multistep process, therefore running a bug bounty program as a complement to this audit is strongly recommended.


-----

**Acknowledged(June 4th 2021): Fortune Cookie team has acknowledged the issue.**

This is an intentional functionality by the dev team.

**Explanation by the team:**

_“We can use the addWinner function to modify the lastWinner variable when we carry_
_out manual mega lottery events. It cannot be set to onlyOwner as we have renounced_
_ownership. Modifying the last winner will not affect the main lottery logic in any way as_
_being marked as a winner has no effect on the lottery other than recognition purposes._
_Moreover, we have a telegram bot that tracks the winner list by the LotteryWon event_
_and hence that too will not be affected by this function being public.”_

