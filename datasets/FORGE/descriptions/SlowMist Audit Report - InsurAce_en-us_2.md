#### 4.3.1.2 Missing permission check

###### The addCoverOwner function does not perform permission checking, any user can call this function

 to add owner. It is recommended to add permission check code.

  contracts/cover/CoverData.sol


**function addCoverOwner(address owner) public {**


require(owner != address(0), "ACO: 1");


require(!allCoverOwnerFlagMap[owner], "ACO: 2");


allCoverOwnerList.push(owner);


allCoverOwnerFlagMap[owner] = true;


}


###### Fix Status: The issues has been fixed.

