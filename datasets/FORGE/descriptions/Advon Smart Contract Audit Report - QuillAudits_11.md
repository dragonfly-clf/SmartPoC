12. Low code and documentation readability 

 Description

 The whitepaper only accounts for 95% of the token supply, there is an unspecified 5% allocation. The codebase contains many typos, and does not conform to the recommended Solidity standard of code formatting. 
 The error message for transfers is inaccurate. Due to the variable nature of saleEndTime, the message ‘after one year’ can be wrong if saleEndTime is shorter or longer.

 require(block.timestamp>contractCreatedTime+saleEndTime,"only can transfer after one year")

 Remediation

 Ensure that the contract code matches the documentation provided. To improve the ease of reading the codebase, it can be passed through a spellcheck and the tool “Prettier” can be used on the contract to aid formatting.

 Status

 Resolved

 General Recommendations

 Reduce frontrunning risk by performing all function calls in the single deployment / initialize step. Addresses can be assigned during contract creation and set as constant or immutable to reduce contract size. 
 Remove redundant variables, e.g. tradeLimit and tradeablePercent if they point to the same thing.
 Pack storage for less accessed storage variables