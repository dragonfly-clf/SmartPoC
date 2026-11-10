#### 4.3.3.4 Overflow risk

###### safemath should be used to calculate the length of the array to avoid overflow issues: if Currency is

 not added, the removal may cause overflow issues.

  contracts/cover/CoverConfig.sol

 32


-----

**function removeCurrency(address currency) external allowedCaller {**


require(currency != address(0), "RC: 1");


uint256 arrayLength = currencyValidAddressArray.length;


uint256 indexToBeDeleted;


bool toDelete = false;


**for (uint256 i = 0; i < arrayLength; i++) {**


**if (currencyValidAddressArray[i] == currency) {**


indexToBeDeleted = i;


toDelete = true;


**break;**


}


}


**if (!toDelete) {**


require(toDelete, "RC: 1");


}


// if index to be deleted is not the last index, swap position.


**if (indexToBeDeleted < arrayLength - 1) {**


currencyValidAddressArray[indexToBeDeleted] = currencyValidAddressArray[arrayLength - 1];


}


// we can now reduce the array length by 1


currencyValidAddressArray.pop();


**delete currencyValidAddressMap[currency];**


}


###### Fix Status: This issue has been fixed.

