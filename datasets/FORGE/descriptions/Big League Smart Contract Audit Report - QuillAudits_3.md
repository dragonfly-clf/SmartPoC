#### Informational

###### 7. Gas costs optimization

 Description Storage variables can be packed together to reduce storage slot usage and can help in saving gas costs. uint8, bool variables can be clubbed with address variables to save gas. Each storage slot costs around ~20000 in gas. In the codebase with optimum packing, the savings can be around ~60000 gas.

 Remediation Optimize storage variables to save gas. Few optimizations could be:
 - Packing uint8, bool variables together with address variables.
 - Across the codebase, uint256 variables have a very small value. Analyze the scope of the highest value possible for these addresses, and if a smaller data type can be used, then use it.

 Status: Open

 0508