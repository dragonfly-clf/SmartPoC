#### 4.3.3.1 Excessive authority issue

###### Admin has permission to add sender, There is a issues of excessive authority. It is recommended to

 set Owner to Timelock contract or governance contract.

  contracts/token/INSURToken.sol


**function addSender(address _from) external onlyAdmin {**


**if (1 == transferFromAllowedList[_from]) {**


**return;**


}


membersFrom.push(_from);


transferFromAllowedList[_from] = 1;


}


###### The admin can remove the sender arbitrarily, and there is a risk of denial of service. When the admin

 adds too many senders, the data in the memberFrom array will be very large, so when the

 removeSender is removed, the depth of the for loop call will be too large, resulting in The call fails. It

 28


-----

###### is recommended to change memberFrom to storage in the way of mapping, and use address as the

 key to avoid dos caused by this type of looping to obtain data.

  contracts/token/INSURToken.sol


**function removeSender(address _from) external onlyAdmin {**


uint256 arrayLength = membersFrom.length;


uint256 indexToBeDeleted;


bool toDelete = false;


**for (uint256 i = 0; i < arrayLength; i++) {**


**if (membersFrom[i] == _from) {**


indexToBeDeleted = i;


toDelete = true;


**break;**


}


}


**if (!toDelete) {**


**return;**


}


// if index to be deleted is not the last index, swap position.


**if (indexToBeDeleted < arrayLength - 1) {**


membersFrom[indexToBeDeleted] = membersFrom[arrayLength - 1];


}


// we can now reduce the array length by 1


membersFrom.pop();


**delete transferFromAllowedList[_from];**


}


###### MINTER can call mint arbitrarily, and there is no upper limit for minting.

  contracts/token/INSURToken.sol


**function mint(address to, uint256 amount) public virtual {**


require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have minter role to mint");


_mint(to, amount);


}


###### Fix Status: This issue has been confirmed，after communication and feedback, the minting and

 Owner permissions may be transferred to address(0) in the future.

 29


-----

###### Owner can set lpTokenMinter and lpTokenBurner. The roles of lpTokenMinter and lpTokenBurner can

 mint and burn the user's LP. There is a issues of excessive authority. It is recommended to set Owner

 to Timelock contract or governance contract. And make sure the lpTokenMinter and lpTokenBurner

 cannot be EOA account.

  contracts/token/LPToken.sol


**function setup(address _lpTokenMinter, address _lpTokenBurner) external onlyOwner {**


require(_lpTokenMinter != address(0), "S:1");


lpTokenMinter = _lpTokenMinter;


require(_lpTokenBurner != address(0), "S:2");


lpTokenBurner = _lpTokenBurner;


}


###### Fix Status: This issue has been communicated back to the project team. The project team is aware of

 this and will adopt governance mechanism to secure the permission when the governance module

 goes live.

