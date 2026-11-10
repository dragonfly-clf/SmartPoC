pragma solidity ^0.8.26;

contract Wallet {
    uint[] private bonusCodes;
    address private owner;
    mapping(address => uint) public userPoints;
    uint public totalDeposits;
    uint public constant POINTS_PER_ETH = 100;
    
    event BonusCodeAdded(address indexed user, uint code);
    event PointsEarned(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);

    constructor() {
        bonusCodes = new uint[](0);
        owner = msg.sender;
    }

    receive() external payable {
        totalDeposits += msg.value;
        uint points = msg.value * POINTS_PER_ETH;
        userPoints[msg.sender] += points;
        emit PointsEarned(msg.sender, points);
    }

    function PushBonusCode(uint c) public {
        bonusCodes.push(c);
        userPoints[msg.sender] += 10;
        emit BonusCodeAdded(msg.sender, c);
    }

    function PopBonusCode() public {
        unchecked {
            require(0 <= bonusCodes.length);
            bonusCodes.pop();
        }
    }

    function UpdateBonusCodeAt(uint idx, uint c) public {
        require(idx < bonusCodes.length);
        bonusCodes[idx] = c;
    }

    function withdrawPoints(uint amount) public {
        require(userPoints[msg.sender] >= amount, "Insufficient points");
        userPoints[msg.sender] -= amount;
        uint ethAmount = amount / POINTS_PER_ETH;
        payable(msg.sender).transfer(ethAmount);
        emit Withdrawal(msg.sender, ethAmount);
    }

    function Destroy() public {
        require(msg.sender == owner);
        selfdestruct(payable(msg.sender));
    }
}