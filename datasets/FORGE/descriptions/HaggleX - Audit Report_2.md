#### Low severity issues

##### 1. The function mintToMultipleAddresses takes in an array of addresses as input but ​ ​ takes a single amount parameter to mint the same amount to all the provided addresses. This makes the bulk mint function less flexible.
 We recommend also making the amount parameter as an array and adding a require statement that ensures that the length of addresses and amounts arrays are the same. If this is an intended behavior then this issue can be ignored.
 2. There are multiple instances in the contract where the array length is calculated inside the for loop definition. As an example:

 In such cases, address.length is called each time the for loop is executed which uses a lot of gas.

This audit does not provide a security or correctness guarantee of the audited smart contract. Securing smart contracts is a
multistep process, therefore running a bug bounty program as a complement to this audit is strongly recommended.