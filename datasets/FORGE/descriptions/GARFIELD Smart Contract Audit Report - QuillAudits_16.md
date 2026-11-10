14. State Variable Default Visibility

 Description There is an instance in the codebase where the require statement has ambiguous or imprecise error messages. 

 L1343: require(balanceOf(msg.sender) >= 0, 'Error: must own MRAT to claim reward');

 0514


-----

###### Uninformative error messages greatly damage the overall user experience, thus lowering the system’s quality. Consider not only fixing the specific instance mentioned above, but also reviewing the entire codebase to make sure every error message is informative and user- friendly.

 Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit 7bfdc0fc6ff8f4027d6fc83c4682d0107b46d302

 