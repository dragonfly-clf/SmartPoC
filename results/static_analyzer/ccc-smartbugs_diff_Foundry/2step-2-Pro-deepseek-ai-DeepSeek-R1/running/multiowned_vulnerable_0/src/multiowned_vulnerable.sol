pragma solidity ^0.8.26;

contract MultiOwnable {
    address public root;
    mapping (address => address) public owners;
    uint public totalDeposits;
    mapping(address => uint) public userDeposits;

    constructor() {
        root = msg.sender;
        owners[root] = root;
    }

    modifier onlyOwner() {
        require(owners[msg.sender] != address(0));
        _;
    }

    function newOwner(address _owner) external returns (bool) {
        require(_owner != address(0));
        owners[_owner] = msg.sender;
        return true;
    }

    function deleteOwner(address _owner) external onlyOwner returns (bool) {
        require(owners[_owner] == msg.sender || (owners[_owner] != address(0) && msg.sender == root));
        owners[_owner] = address(0);
        return true;
    }

    function deposit() external payable {
        totalDeposits += msg.value;
        userDeposits[msg.sender] += msg.value;
    }
}

contract TestContract is MultiOwnable {
    uint public ownerWithdrawals;
    
    function withdrawAll() external onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
        ownerWithdrawals += balance;
    }

    function getUserBalance(address user) external view returns (uint) {
        return userDeposits[user];
    }

    receive() external payable {
        totalDeposits += msg.value;
        userDeposits[msg.sender] += msg.value;
    }
}