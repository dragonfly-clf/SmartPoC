#### Commented Code exist

###### There are some instances of code being commented out in the following files that should be removed:


Line Comment

453 // function getCollectedFeeTotal(uint256 index) external view returns (uint256){

782-784 // address private _mainnetRouterV1Address =
0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
[// PancakeSwap Testnet = https://pancake.kiemtienonline360.com/](https://pancake.kiemtienonline360.com/)
// address private _mainnetRouterV2Address =
0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

812 // else (_env == Env.Testnet) { _setRouterAddress(_testnetRouterAddress); }

970 // function _getAntiwhaleFees(uint256 sendersBalance, uint256 amount) internal view
returns (uint256){

983 // constructor(string memory _name, string memory _symbol, uint8 _decimals){

##### Recommendation

###### Remove the commented code, or address them properly.


#### Audit Comments

##### 15. August 2021:

###### • There is still an owner (Owner still has not renounced ownership)


21

|Line|Comment|
|---|---|
|453|// function getCollectedFeeTotal(uint256 index) external view returns (uint256){|
|782-784|// address private _mainnetRouterV1Address = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // PancakeSwap Testnet = https://pancake.kiemtienonline360.com/ // address private _mainnetRouterV2Address = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;|
|812|// else (_env == Env.Testnet) { _setRouterAddress(_testnetRouterAddress); }|
|970|// function _getAntiwhaleFees(uint256 sendersBalance, uint256 amount) internal view returns (uint256){|
|983|// constructor(string memory _name, string memory _symbol, uint8 _decimals){|


// address private _mainnetRouterV1Address =
0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
[// PancakeSwap Testnet = https://pancake.kiemtienonline360.com/](https://pancake.kiemtienonline360.com/)
// address private _mainnetRouterV2Address =
0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

// else (_env == Env.Testnet) { _setRouterAddress(_testnetRouterAddress); }

// function _getAntiwhaleFees(uint256 sendersBalance, uint256 amount) internal view
returns (uint256){

// constructor(string memory _name, string memory _symbol, uint8 _decimals){

##### Recommendation

###### Remove the commented code, or address them properly.


