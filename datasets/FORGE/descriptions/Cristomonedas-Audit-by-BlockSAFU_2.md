High-Risk

 3 high-risk code issues found

 Must be fixed, and will bring problems.

1. Owner can set blacklist address

**Risk scenario: owner can blacklist you, and you cannot sell your assets.**

**Recommendation: remove this function**
```
      function Launch_Settings_01__Blacklist_Bots(
           address Wallet,
           bool true_or_false
           ) external onlyOwner {
           // Buyer Protection - Blacklisting can only be done before
      launch
           if (true_or_false){require(LaunchTime == 0, "E08");}
           _isBlacklisted[Wallet] = true_or_false;
         }

```
2. Owner can sell before starting trading.

**Risk scenario: owner can sell all developer unlock tokens before the transaction starts.**

**Recommendation: remove this function or set everyone can’t sell including the owner.**
```
      function Launch_Settings_03__OpenTrade() external onlyOwner {
           // Can only use once!
           require(!TradeOpen, "E09");
           TradeOpen = true;
           swapAndLiquifyEnabled = true;
           LaunchPhase = true;
           LaunchTime = block.timestamp;
           emit updated_trade_Open(TradeOpen);
           emit

```

-----

```
      updated_SwapAndLiquify_Enabled(swapAndLiquifyEnabled);
           // Set the contract fee if required
           Fee_Buy_Contract  = ContractFee;
           Fee_Sell_Contract = ContractFee;
           SwapFeeTotal_Buy  = _FeeBuy_Liquidity + _FeeBuy_BNB +
      _Fee_Buy_Contract;
           SwapFeeTotal_Sell  = _FeeSell_Liquidity + _FeeSell_BNB +
      _Fee_Sell_Contract;
           emit set_Contract_Fee(FeeBuy_Contract,
      _Fee_Sell_Contract);
         }

```
3. Owner can set Max tx Amount without no limit

**Risk scenario: owner can set 0 (zero) Tokens. This will cause a honeypot.**

**Recommendation: remove this function or set limit more than 0.1% total supply**
```
       function Contract_SetUp_03__Wallet_Limits(
           uint256 Max_Tokens_Per_Transaction,
           uint256 Max_Total_Tokens_Per_Wallet
           ) external onlyOwner {
           // Buyer protection - Limits must be set to greater than
      0.1% of total supply
           require(Max_Tokens_Per_Transaction >= _tTotal / 1000 /
      10**_decimals, "E04");
           require(Max_Total_Tokens_Per_Wallet >= _tTotal / 1000 /
      10**_decimals, "E05");
           max_Tran = Max_Tokens_Per_Transaction * 10**_decimals;
           max_Hold = Max_Total_Tokens_Per_Wallet * 10**_decimals;
           emit updated_Wallet_Limits(max_Tran, max_Hold);
         }

```

-----

#### 