pragma solidity ^0.8.26;

contract Refunder {
    address[] private refundAddresses;
    mapping(address => uint256) public refunds;
    address public owner;
    uint256 public totalRefunded;
    uint256 public serviceFee;

    event RefundProcessed(address indexed recipient, uint256 amount);
    event FundsAdded(address indexed depositor, uint256 amount);

    constructor() {
        refundAddresses.push(0x79B483371E87d664cd39491b5F06250165e4b184);
        refundAddresses.push(0x79B483371E87d664cd39491b5f06250165e4b185);
        owner = msg.sender;
        serviceFee = 0.001 ether;
    }

    function addFunds() external payable {
        require(msg.value > 0, "Must send some ETH");
        refunds[msg.sender] += msg.value;
        emit FundsAdded(msg.sender, msg.value);
    }

    function refundAll() public {
        for (uint256 x = 0; x < refundAddresses.length; x++) {
            uint256 refundAmount = refunds[refundAddresses[x]];
            if (refundAmount > 0) {
                require(payable(refundAddresses[x]).send(refundAmount));
                totalRefunded += refundAmount;
                refunds[refundAddresses[x]] = 0;
                emit RefundProcessed(refundAddresses[x], refundAmount);
            }
        }
    }

    function withdrawFee() external {
        require(msg.sender == owner, "Only owner can withdraw fees");
        payable(owner).transfer(serviceFee);
    }
}