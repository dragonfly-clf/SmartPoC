## 22


-----

onlyOwner {

require(destination_ != address(0), "Withdrawable: Destination is zero address");

uint256 availableAmount;

if(token_ == address(0)) {

availableAmount = address(this).balance;

} else {

availableAmount = IERC20(token_).balanceOf(address(this));

}

require(amount_ <= availableAmount, "Withdrawable: Not enough balance");

if(token_ == address(0)) {

**//SlowMist// There is no upper limit of the gas to execute the low-level call**

**to withdraw the native tokens**

destination_.call{value:amount_}("");

} else {

IERC20(token_).safeTransfer(destination_, amount_);

}

emit Withdrawn(_msgSender(), destination_, token_, amount_);

}

/// @dev withdraw NFT from contract

/// @param token_ address of the token, use address(0) to withdraw gas token

/// @param destination_ recipient address to receive the fund

/// @param tokenId_ ID of NFT to withdraw

**//SlowMist// The owner role can withdraw the any NFT tokens from this contract to a**

**specific address**

function withdrawNft(address token_, address destination_, uint256 tokenId_)

external onlyOwner {

require(destination_ != address(0), "Withdrawable: destination is zero address");

IERC721(token_).transferFrom(address(this), destination_, tokenId_);

emit Withdrawn(_msgSender(), destination_, token_, 1);

}

}

/**

- @dev Implementation of the {IERC20} interface.


- This implementation is agnostic to the way tokens are created. This means

- that a supply mechanism has to be added in a derived contract using {_mint}.


## 23


-----

- For a generic mechanism see {ERC20PresetMinterPauser}.


- TIP: For a detailed writeup see our guide

- https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply
mechanisms/226[How

- to implement supply mechanisms].


- We have followed general OpenZeppelin guidelines: functions revert instead

- of returning `false` on failure. This behavior is nonetheless conventional

- and does not conflict with the expectations of ERC20 applications.


- Additionally, an {Approval} event is emitted on calls to {transferFrom}.

- This allows applications to reconstruct the allowance for all accounts just

- by listening to said events. Other implementations of the EIP may not emit

- these events, as it isn't required by the specification.


- Finally, the non-standard {decreaseAllowance} and {increaseAllowance}

- functions have been added to mitigate the well-known issues around setting

- allowances. See {IERC20-approve}.

*/

contract CUSD is Context, Ownable, Pausable, Blacklistable, Withdrawable, IERC20 {

using SafeMath for uint256;

uint256 private _totalSupply;

string private constant _name = "Coin98 Dollar";

string private constant _symbol = "CUSD";

uint8 private constant _decimals = 18;

mapping (address => uint256) private _balances;

mapping (address => mapping (address => uint256)) private _allowances;

address private _minter;

/**

- @dev Sets the values for {name} and {symbol}, initializes {decimals} with

- a default value of 18.


- To select a different value for {decimals}, use {_setupDecimals}.


- All three of these values are immutable: they can only be set once during

- construction.

*/


## 24


-----

constructor() {

_minter = _msgSender();

}

/**

@dev Emit when new minter is assigned

*/

event MinterUpdated(address indexed previousMinter, address indexed newMinter);

/**

- @dev Returns the name of the token.

*/

function name() public view returns (string memory) {

return _name;

}

/**

- @dev Returns the symbol of the token, usually a shorter version of the

- name.

*/

function symbol() public view returns (string memory) {

return _symbol;

}

/**

- @dev Returns the number of decimals used to get its user representation.

- For example, if `decimals` equals `2`, a balance of `505` tokens should

- be displayed to a user as `5,05` (`505 / 10 ** 2`).


- Tokens usually opt for a value of 18, imitating the relationship between

- Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is

- called.


- NOTE: This information is only used for _display_ purposes: it in

- no way affects any of the arithmetic of the contract, including

- {IERC20-balanceOf} and {IERC20-transfer}.

*/

function decimals() public view returns (uint8) {

return _decimals;

}

/**

- @dev See {IERC20-totalSupply}.

*/


## 25


-----

function totalSupply() public view override returns (uint256) {

return _totalSupply;

}

/**

- @dev See {IERC20-balanceOf}.

*/

function balanceOf(address account) public view override returns (uint256) {

return _balances[account];

}

/**

@dev Extra address which has priviledge to mint more token

*/

function minter() public view returns (address) {

return _minter;

}

/**

- @dev Throws if called by any account other than the owner or minter.

*/

modifier onlyMinter() {

require(owner() == _msgSender() || _minter == _msgSender(), "ERC20: caller is not

minter");

_;

}

/**

- @dev See {IERC20-transfer}.


- Requirements:


- - `recipient` cannot be the zero address.

- - the caller must have a balance of at least `amount`.

*/

function transfer(address recipient, uint256 amount) public override

notBlacklisted(_msgSender())

notBlacklisted(recipient)

returns (bool)

{

_transfer(_msgSender(), recipient, amount);

**//SlowMist// The return value conforms to the EIP20 specification**

return true;

}


## 26


-----

/**

- @dev See {IERC20-allowance}.

*/

function allowance(address owner, address spender) public view override returns

(uint256) {

return _allowances[owner][spender];

}

/**

- @dev See {IERC20-approve}.


- Requirements:


- - `spender` cannot be the zero address.

*/

function approve(address spender, uint256 amount) public override

notBlacklisted(_msgSender())

notBlacklisted(spender)

returns (bool)

{

_approve(_msgSender(), spender, amount);

**//SlowMist// The return value conforms to the EIP20 specification**

return true;

}

/**

- @dev See {IERC20-transferFrom}.


- Emits an {Approval} event indicating the updated allowance. This is not

- required by the EIP. See the note at the beginning of {ERC20}.


- Requirements:


- - `sender` and `recipient` cannot be the zero address.

- - `sender` must have a balance of at least `amount`.

- - the caller must have allowance for ``sender``'s tokens of at least

- `amount`.

*/

function transferFrom(address sender, address recipient, uint256 amount) public

override

notBlacklisted(_msgSender())

notBlacklisted(sender)

notBlacklisted(recipient)


## 27


-----

returns (bool)

{

_transfer(sender, recipient, amount);

_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount,

"ERC20: transfer amount exceeds allowance"));

**//SlowMist// The return value conforms to the EIP20 specification**

return true;

}

/**

- @dev Atomically increases the allowance granted to `spender` by the caller.


- This is an alternative to {approve} that can be used as a mitigation for

- problems described in {IERC20-approve}.


- Emits an {Approval} event indicating the updated allowance.


- Requirements:


- - `spender` cannot be the zero address.

*/

function increaseAllowance(address spender, uint256 addedValue) public

notBlacklisted(_msgSender())

notBlacklisted(spender)

returns (bool)

{

_approve(_msgSender(), spender, _allowances[_msgSender()]

[spender].add(addedValue));

return true;

}

/**

- @dev Atomically decreases the allowance granted to `spender` by the caller.


- This is an alternative to {approve} that can be used as a mitigation for

- problems described in {IERC20-approve}.


- Emits an {Approval} event indicating the updated allowance.


- Requirements:


- - `spender` cannot be the zero address.

- - `spender` must have allowance for the caller of at least

- `subtractedValue`.


