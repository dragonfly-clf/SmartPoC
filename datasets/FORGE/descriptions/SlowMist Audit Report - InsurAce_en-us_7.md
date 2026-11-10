#### 4.3.3.2 DoS issue

###### The incoming _callers will add data to allowedCallersArray[_callee]. If too many _callers are added at

 one time, it will cause Out of Gas. When there are too many data in allowedCallersArray[_callee], the

 setAllowdCallersPerCallee function will DoS. It is recommended to set the data Use the mapping

 method to store instead, avoid using the for loop to find the value.

  contracts/secmatrix/SecurityMatrix.sol


**function addAllowdCallersPerCallee(address _callee, address[] memory _callers) external onlyOwner {**


require(_callers.length != 0, "AACPC:1");


require(allowedCallersArray[_callee].length != 0, "AACPC:2");


**for (uint256 index = 0; index < _callers.length; index++) {**


console.log("_callers index: ", _callers[index], index);


allowedCallersArray[_callee].push(_callers[index]);


###### 30


-----

allowedCallersMap[_callee][_callers[index]] = 1;


}


}


######  contracts/secmatrix/SecurityMatrix.sol


**function setAllowdCallersPerCallee(address _callee, address[] memory _callers) external onlyOwner {**


console.log("_callee: ", _callee);


console.log("_callers.length: ", _callers.length);


require(_callers.length != 0, "SACPC:1");


// check if callee exist


**if (allowedCallersArray[_callee].length == 0) {**


// not exist, so add callee


allowedCallees.push(_callee);


} else {


// if callee exist, then purge data


**for (uint256 i = 0; i < allowedCallersArray[_callee].length; i++) {**


**delete allowedCallersMap[_callee][allowedCallersArray[_callee][i]];**


}


**delete allowedCallersArray[_callee];**


}


// and overwrite


**for (uint256 index = 0; index < _callers.length; index++) {**


console.log("_callers index: ", _callers[index], index);


allowedCallersArray[_callee].push(_callers[index]);


allowedCallersMap[_callee][_callers[index]] = 1;


}


}


###### Fix Status: This issue has been communicated back to project team. The project team is aware of

 this issue and the method will only be used by admin when setting up security matrix.

 The “setAllowdCallersPerCallee” method will be used to create security matrix entries, and the

 “addAllowdCallersPerCallee” method will be used to add delta matrix if needed.

