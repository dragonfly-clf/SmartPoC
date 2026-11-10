Unchecked Transfer (1 item)
A transfer call made in this contract may be unstable and cause tokens to
become stuck

```
**Function** **Severity** **Relevant Snippet**
```
SlappyCat.claimStuckTokens
(address)
                     function
(SlappyCat.sol#563-572)
ignores return value by Severity claimStuckTokens(address
                    : High token) external onlyOwner {
ERC20token.transfer(msg.se
                       require(token !=
nder,balance)
                     address(this), "Owner cannot
(SlappyCat.sol#571)
                     claim native tokens");
                       if (token == address(0x0))
                     {
                     payable(msg.sender).sendValue(
                     address(this).balance);
                         return;
                       }
                       IERC20 ERC20token =
                     IERC20(token);
                       uint256 balance =
                     ERC20token.balanceOf(address(t
                     his));
                     ERC20token.transfer(msg.sender
                    , balance);
                     }

```
|Function|Severity|Relevant Snippet|
|---|---|---|
|SlappyCat.claimStuckTokens (address) (SlappyCat.sol#563-572) ignores return value by ERC20token.transfer(msg.se nder,balance) (SlappyCat.sol#571)|Severity : High|function claimStuckTokens(address token) external onlyOwner { require(token != address(this), "Owner cannot claim native tokens"); if (token == address(0x0)) { payable(msg.sender).sendValue( address(this).balance); return; } IERC20 ERC20token = IERC20(token); uint256 balance = ERC20token.balanceOf(address(t his)); ERC20token.transfer(msg.sender , balance); }|


-----

```
 