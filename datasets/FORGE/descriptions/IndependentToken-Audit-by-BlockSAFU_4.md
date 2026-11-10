EXTRA NOTES SMART CONTRACT

###### 1. IBEP20
```
      interface IBEP20 {
        function totalSupply() external view returns (uint256);
        function decimals() external view returns (uint8);
        function symbol() external view returns (string memory);
        function name() external view returns (string memory);
        function getOwner() external view returns (address);
        function balanceOf(address account) external view returns
      (uint256);
        function transfer(address recipient, uint256 amount) external
      returns (bool);
        function allowance(address _owner, address spender) external
      view returns (uint256);
        function approve(address spender, uint256 amount) external
      returns (bool);
        function transferFrom(address sender, address recipient,
      uint256 amount) external returns (bool);
        event Transfer(address indexed from, address indexed to,
      uint256 value);
        event Approval(address indexed owner, address indexed spender,
      uint256 value);
      }

```
IBEP20 Normal Base Template


-----

**2. SafeMath Contract**
```
      library SafeMath {
      ...
        function add(uint256 a, uint256 b) internal pure returns
      (uint256) {
          uint256 c = a + b;
          require(c >= a, "SafeMath: addition overflow");
          return c;
        }
      ...
        function sub(uint256 a, uint256 b, string memory errorMessage)
      internal pure returns (uint256) {
          require(b <= a, errorMessage);
          uint256 c = a - b;
          return c;
        }
        /**
         * @dev Returns the multiplication of two unsigned integers,
      reverting on
         * overflow.
         *
         * Counterpart to Solidity's `*` operator.
         *
         * Requirements:
         *
         * - Multiplication cannot overflow.
         */
       ...
        function mod(
          uint256 a,
          uint256 b,
          string memory errorMessage
        ) internal pure returns (uint256) {
          unchecked {
             require(b > 0, errorMessage);
             return a % b;
          }
        }
      }

```
Standard Safemath contract


-----

**3. Independent Contract**
```
      contract Independent is IBEP20, Auth {
         using SafeMath for uint256;
         address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
         address DEAD = 0x000000000000000000000000000000000000dEaD;
         address ZERO = 0x0000000000000000000000000000000000000000;
         string constant _name = "Independent TOKEN";
         string constant _symbol = "IDPD";
         uint8 constant _decimals = 9;
         uint256 _totalSupply = 54 * 10**6 * 10**_decimals;
         uint256 public _maxTxAmount = _totalSupply / 50;
         uint256 public _maxWalletToken = _totalSupply / 100;
         mapping (address => uint256) _balances;
         mapping (address => mapping (address => uint256)) _allowances;
         bool public blacklistMode = true;
         mapping (address => bool) public isBlacklisted;
         mapping (address => bool) isFeeExempt;
         mapping (address => bool) isTxLimitExempt;
         mapping (address => bool) isTimelockExempt;
         uint256 public liquidityFee   = 6;
         uint256 public marketingFee   = 8;
         uint256 public projectFee    = 0;
         uint256 public charityFee    = 2;
         uint256 public buyBackFee    = 4;
         uint256 public totalFee     = charityFee + marketingFee +
      liquidityFee + projectFee + buyBackFee;
         uint256 public feeDenominator  = 100;
         uint256 public sellMultiplier = 100;
         uint256 public buyMultiplier  = 0;
         uint256 public transferMultiplier = 50;
         address public autoLiquidityReceiver;
         address public marketingFeeReceiver;

```

-----

```
         address public projectFeeReceiver;
         address public charityFeeReceiver;
         address public buyBackFeeReceiver;
         uint256 targetLiquidity = 30;
         uint256 targetLiquidityDenominator = 100;
         IDEXRouter public router;
         address public pair;
         bool public tradingOpen = false;
         // Cooldown & timer functionality
         bool public buyCooldownEnabled = true;
         uint8 public cooldownTimerInterval = 45;
         mapping (address => uint) private cooldownTimer;
         bool public swapEnabled = true;
         uint256 public swapThreshold = _totalSupply * 10 / 10000;
         bool inSwap;
         modifier swapping() { inSwap = true; _; inSwap = false; }
         constructor () Auth(msg.sender) {
           router =
      IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
           pair = IDEXFactory(router.factory()).createPair(WBNB,
      address(this));
           _allowances[address(this)][address(router)] =
      type(uint256).max;
           isFeeExempt[msg.sender] = true;
           isTxLimitExempt[msg.sender] = true;
           // No timelock for these people
           isTimelockExempt[msg.sender] = true;
           isTimelockExempt[DEAD] = true;
           isTimelockExempt[address(this)] = true;
           autoLiquidityReceiver = msg.sender;
           marketingFeeReceiver = msg.sender;
           projectFeeReceiver = msg.sender;

```

-----

```
           charityFeeReceiver = msg.sender;
           buyBackFeeReceiver = msg.sender;
           _balances[msg.sender] = _totalSupply;
           emit Transfer(address(0), msg.sender, _totalSupply);
         }
         receive() external payable { }
         function totalSupply() external view override returns
      (uint256) { return _totalSupply; }
         function decimals() external pure override returns (uint8) {
      return _decimals; }
         function symbol() external pure override returns (string
      memory) { return _symbol; }
         function name() external pure override returns (string memory)
      { return _name; }
         function getOwner() external view override returns (address) {
      return owner; }
         function balanceOf(address account) public view override
      returns (uint256) { return _balances[account]; }
         function allowance(address holder, address spender) external
      view override returns (uint256) { return
      _allowances[holder][spender]; }
         function approve(address spender, uint256 amount) public
      override returns (bool) {
           _allowances[msg.sender][spender] = amount;
           emit Approval(msg.sender, spender, amount);
           return true;
         }
         function approveMax(address spender) external returns (bool) {
           return approve(spender, type(uint256).max);
         }
         function transfer(address recipient, uint256 amount) external
      override returns (bool) {
           return _transferFrom(msg.sender, recipient, amount);
         }
         function transferFrom(address sender, address recipient,

```

-----

```
      uint256 amount) external override returns (bool) {
           if(_allowances[sender][msg.sender] != type(uint256).max){
             _allowances[sender][msg.sender] =
      _allowances[sender][msg.sender].sub(amount, "Insufficient
      Allowance");
           }
           return _transferFrom(sender, recipient, amount);
         }
         function _transferFrom(address sender, address recipient,
      uint256 amount) internal returns (bool) {
           if(inSwap){ return _basicTransfer(sender, recipient,
      amount); }
           if(!authorizations[sender] && !authorizations[recipient]){
             require(tradingOpen,"Trading not open yet");
           }
           if(blacklistMode){
             require(!isBlacklisted[sender] &&
      !isBlacklisted[recipient],"Blacklisted");
           }
           if (!authorizations[sender] && recipient != address(this)
      && recipient != address(DEAD) && recipient != pair && recipient !=
      buyBackFeeReceiver){
             uint256 heldTokens = balanceOf(recipient);
             require((heldTokens + amount) <=
      _maxWalletToken,"Total Holding is currently limited, you can not
      buy that much.");}
           // cooldown timer, so a bot doesnt do quick trades! 45s
      gap between 2 trades - add buy @lebarhamien
           if (sender == pair &&
             buyCooldownEnabled &&
             !isTimelockExempt[recipient]) {
             require(cooldownTimer[recipient] <
      block.timestamp,"Please wait for cooldown between buys");
             cooldownTimer[recipient] = block.timestamp +
      cooldownTimerInterval;
           }

```

-----

```
           // Checks max transaction limit
           checkTxLimit(sender, amount);
           if(shouldSwapBack()){ swapBack(); }
           //Trade tokens
           _balances[sender] = _balances[sender].sub(amount,
      "Insufficient Balance");
           uint256 amountReceived = (!shouldTakeFee(sender) ||
      !shouldTakeFee(recipient)) ? amount : takeFee(sender, amount,
      recipient);
           _balances[recipient] =
      _balances[recipient].add(amountReceived);
           emit Transfer(sender, recipient, amountReceived);
           return true;
         }
         function _basicTransfer(address sender, address recipient,
      uint256 amount) internal returns (bool) {
           _balances[sender] = _balances[sender].sub(amount,
      "Insufficient Balance");
           _balances[recipient] = _balances[recipient].add(amount);
           emit Transfer(sender, recipient, amount);
           return true;
         }
         function checkTxLimit(address sender, uint256 amount) internal
      view {
           require(amount <= _maxTxAmount || isTxLimitExempt[sender],
      "TX Limit Exceeded");
         }
         function shouldTakeFee(address sender) internal view returns
      (bool) {
           return !isFeeExempt[sender];
         }
         function takeFee(address sender, uint256 amount, address
      recipient) internal returns (uint256) {

```

-----

```
           uint256 multiplier = transferMultiplier;
           if(recipient == pair){
             multiplier = sellMultiplier;
           } else if(sender == pair){
             multiplier = buyMultiplier;
           }
           uint256 feeAmount =
      amount.mul(totalFee).mul(multiplier).div(feeDenominator * 100);
           uint256 buyBackTokens =
      feeAmount.mul(buyBackFee).div(totalFee);
           uint256 contractTokens = feeAmount.sub(buyBackTokens);
           _balances[address(this)] =
      _balances[address(this)].add(contractTokens);
           _balances[buyBackFeeReceiver] =
      _balances[buyBackFeeReceiver].add(buyBackTokens);
           emit Transfer(sender, address(this), contractTokens);
           if(buyBackTokens > 0){
             emit Transfer(sender, buyBackFeeReceiver,
      buyBackTokens);
           }
           return amount.sub(feeAmount);
         }
         function shouldSwapBack() internal view returns (bool) {
           return msg.sender != pair
           && !inSwap
           && swapEnabled
           && _balances[address(this)] >= swapThreshold;
         }
         function swapBack() internal swapping {
           uint256 dynamicLiquidityFee =
      isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 :
      liquidityFee;
           uint256 amountToLiquify =
      swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);

```

-----

```
           uint256 amountToSwap = swapThreshold.sub(amountToLiquify);
           address[] memory path = new address[](2);
           path[0] = address(this);
           path[1] = WBNB;
           uint256 balanceBefore = address(this).balance;
           router.swapExactTokensForETHSupportingFeeOnTransferTokens(
             amountToSwap,
             0,
             path,
             address(this),
             block.timestamp
           );
           uint256 amountBNB =
      address(this).balance.sub(balanceBefore);
           uint256 totalBNBFee =
      totalFee.sub(dynamicLiquidityFee.div(2));
           uint256 amountBNBLiquidity =
      amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
           uint256 amountBNBMarketing =
      amountBNB.mul(marketingFee).div(totalBNBFee);
           uint256 amountBNBcharityFee =
      amountBNB.mul(charityFee).div(totalBNBFee);
           uint256 amountBNBproject =
      amountBNB.mul(projectFee).div(totalBNBFee);
           (bool tmpSuccess,) =
      payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas:
      30000}("");
           (tmpSuccess,) = payable(projectFeeReceiver).call{value:
      amountBNBproject, gas: 30000}("");
           (tmpSuccess,) = payable(charityFeeReceiver).call{value:
      amountBNBcharityFee, gas: 30000}("");
           tmpSuccess = false;
           if(amountToLiquify > 0){

```

-----

```
             router.addLiquidityETH{value: amountBNBLiquidity}(
               address(this),
               amountToLiquify,
               0,
               0,
               autoLiquidityReceiver,
               block.timestamp
             );
             emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
           }
         }
         // Public function
         function setMaxWalletPercent_base1000(uint256
      maxWallPercent_base1000) external onlyOwner() {
           _maxWalletToken = (_totalSupply * maxWallPercent_base1000
      ) / 1000;
         }
         function setMaxTxPercent_base1000(uint256
      maxTXPercentage_base1000) external onlyOwner() {
           _maxTxAmount = (_totalSupply * maxTXPercentage_base1000 )
      / 1000;
         }
         function setMaxTxAbsolute(uint256 amount) external authorized
      {
           _maxTxAmount = amount;
         }
         function clearStuckBalance(uint256 amountPercentage) external
      authorized {
           uint256 amountBNB = address(this).balance;
           payable(msg.sender).transfer(amountBNB * amountPercentage
      / 100);
         }
         // enable cooldown between trades buy @lebarhamien
         function cooldownEnabled(bool _status, uint8 _interval) public
      onlyOwner {
           buyCooldownEnabled = _status;
           cooldownTimerInterval = _interval;
         }

```

-----

```
         function setMultipliers(uint256 _buy, uint256 _sell, uint256
      _trans) external onlyOwner{
           sellMultiplier = _sell;
           buyMultiplier = _buy;
           transferMultiplier = _trans;
         }
         function tradingStatus(bool _status) external onlyOwner {
           tradingOpen = _status;
         }
         function manage_blacklist_status(bool _status) external
      onlyOwner {
           blacklistMode = _status;
         }
         function manage_blacklist(address[] calldata addresses, bool
      status) external onlyOwner {
           require(addresses.length < 501,"GAS Error: max limit is
      500 addresses");
           for (uint256 i; i < addresses.length; ++i) {
             isBlacklisted[addresses[i]] = status;
           }
         }
         function manage_FeeExempt(address[] calldata addresses, bool
      status) external onlyOwner {
           require(addresses.length < 501,"GAS Error: max limit is
      500 addresses");
           for (uint256 i; i < addresses.length; ++i) {
             isFeeExempt[addresses[i]] = status;
           }
         }
         function manage_TxLimitExempt(address[] calldata addresses,
      bool status) external onlyOwner {
           require(addresses.length < 501,"GAS Error: max limit is
      500 addresses");
           for (uint256 i; i < addresses.length; ++i) {
             isTxLimitExempt[addresses[i]] = status;
           }

```

-----

```
         }
         function setIsFeeExempt(address holder, bool exempt) external
      authorized {
           isFeeExempt[holder] = exempt;
         }
         function setIsTxLimitExempt(address holder, bool exempt)
      external authorized {
           isTxLimitExempt[holder] = exempt;
         }
         function setIsTimelockExempt(address holder, bool exempt)
      external authorized {
           isTimelockExempt[holder] = exempt;
         }
         function setFees(uint256 _liquidityFee, uint256 _charityFee,
      uint256 _marketingFee, uint256 _projectFee, uint256 _buyBackFee,
      uint256 _feeDenominator) external authorized {
           liquidityFee = _liquidityFee;
           charityFee = _charityFee;
           marketingFee = _marketingFee;
           projectFee = _projectFee;
           buyBackFee = _buyBackFee;
           totalFee =
      _liquidityFee.add(_charityFee).add(_marketingFee).add(_projectFee)
      .add(_buyBackFee);
           feeDenominator = _feeDenominator;
           require(totalFee < feeDenominator/2, "Fees cannot be more
      than 50%");
         }
         function setFeeReceivers(address _autoLiquidityReceiver,
      address _marketingFeeReceiver, address _projectFeeReceiver,
      address _buyBackFeeReceiver, address _charityFeeReceiver) external
      authorized {
           autoLiquidityReceiver = _autoLiquidityReceiver;
           marketingFeeReceiver = _marketingFeeReceiver;
           projectFeeReceiver = _projectFeeReceiver;
           buyBackFeeReceiver = _buyBackFeeReceiver;
           charityFeeReceiver = _charityFeeReceiver;

```

-----

```
         }
         function setSwapBackSettings(bool _enabled, uint256 _amount)
      external authorized {
           swapEnabled = _enabled;
           swapThreshold = _amount;
         }
         function setTargetLiquidity(uint256 _target, uint256
      _denominator) external authorized {
           targetLiquidity = _target;
           targetLiquidityDenominator = _denominator;
         }
         function getCirculatingSupply() public view returns (uint256)
      {
           return
      _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
         }
         function getLiquidityBacking(uint256 accuracy) public view
      returns (uint256) {
           return
      accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
         }
         function isOverLiquified(uint256 target, uint256 accuracy)
      public view returns (bool) {
           return getLiquidityBacking(accuracy) > target;
         }
         function multiTransfer(address from, address[] calldata
      addresses, uint256[] calldata tokens) external onlyOwner {
           require(addresses.length < 501,"GAS Error: max airdrop
      limit is 500 addresses");
           require(addresses.length == tokens.length,"Mismatch
      between Address and token count");
           uint256 SCCC = 0;
           for(uint i=0; i < addresses.length; i++){

```

-----

```
             SCCC = SCCC + tokens[i];
           }
           require(balanceOf(from) >= SCCC, "Not enough tokens in
      wallet");
           for(uint i=0; i < addresses.length; i++){
             _basicTransfer(from,addresses[i],tokens[i]);
           }
         }
      event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
      }

```

-----

**4. Tax Fee contract**
```
      function setFees(uint256 _liquidityFee, uint256 _charityFee,
      uint256 _marketingFee, uint256 _projectFee, uint256 _buyBackFee,
      uint256 _feeDenominator) external authorized {
          liquidityFee = _liquidityFee;
          charityFee = _charityFee;
          marketingFee = _marketingFee;
          projectFee = _projectFee;
          buyBackFee = _buyBackFee;
          totalFee =
      _liquidityFee.add(_charityFee).add(_marketingFee).add(_projectFee)
      .add(_buyBackFee);
          feeDenominator = _feeDenominator;
          require(totalFee < feeDenominator/2, "Fees cannot be more
      than 50%");
        }

```
The owner can set fees over 25% (49%) - Medium risk

**5. Blacklist**
```
      function manage_blacklist(address[] calldata addresses, bool
      status) external onlyOwner {
          require(addresses.length < 501,"GAS Error: max limit is
      500 addresses");
          for (uint256 i; i < addresses.length; ++i) {
             isBlacklisted[addresses[i]] = status;
          }
        }

```
The owner can set blacklist Address. - warning

**6. maxTxAmount**
```
      function setMaxTxAbsolute(uint256 amount) external authorized {
           _maxTxAmount = amount;
         }

```
The Owner can set max tx amount < 0.1 from total supply -warning

**7. Hidden Owner**
```
      function authorize(address adr) public onlyOwner {
           authorizations[adr] = true;
         }

###### The owner can set hidden owner -warning

```

-----

#### 