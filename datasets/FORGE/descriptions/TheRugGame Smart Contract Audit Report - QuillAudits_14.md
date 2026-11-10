2. Centralization Risk

 Description

 The onlyOwner functions such as changeCult(), changeDCult(), changeTrg() and emergencyRemoveToken() can be exploited by a malicious admin resulting in a potential Denial of Service attack to users. For example, if the cult and the trg address is changed by a malicious admin to point to some other address, the users will not be able to call the bribe() function because it will lead to execution of the if statement on line: 163 resulting in Denial of Service attack. Additionally emergencyRemoveToken() can be used by a malicious admin to remove tokens that are unfavourable to the winning conditions and can be used to manipulate the game.

 Recommendation

 It is advised to implement a multi-sig to prevent loss of private keys. Additionally it is advised to set up a governance system to prevent unauthorized changes to state if a compromised contract owner calls the affected functions.

TheRugGame - Audit Report

###### Status

 Acknowledged

 Low Severity Issues

 