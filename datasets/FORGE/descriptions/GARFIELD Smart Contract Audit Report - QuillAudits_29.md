26. Use double quotes for string literals

 Line Code

 require(nextAvailableClaimDate[msg.sender] <= block.timestamp, 'Error:
 1342-1343
 next available not reached');     require(balanceOf(msg.sender) >= 0, 'Error: must own MRAT to claim reward');

 require(sent, 'Error: Cannot withdraw reward');
 1362

 0521


-----

###### Description Single quote found in the above string variables. Whilst, the double quotes are being utilized for other string literals.

 Remediation We recommend using double quotes for string literals.

 Status: Closed The Garfield team made some fixes based on our recommendations.

 