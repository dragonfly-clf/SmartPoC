pragma solidity ^0.8.26;

contract FibonacciBalance {
    address public fibonacciLibrary;
    uint public calculatedFibNumber;
    uint public start = 3;
    uint public withdrawalCounter;
    bytes4 constant fibSig = bytes4(keccak256("setFibonacci(uint256)"));
    mapping(address => uint) public userBalances;
    uint public totalWithdrawals;
    
    event Withdrawal(address indexed user, uint amount);
    event Deposit(address indexed user, uint amount);

    constructor(address _fibonacciLibrary) payable {
        fibonacciLibrary = _fibonacciLibrary;
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        userBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() public {
        withdrawalCounter += 1;
        (bool success, ) = fibonacciLibrary.delegatecall(abi.encodeWithSelector(fibSig, withdrawalCounter));
        require(success);
        uint withdrawAmount = calculatedFibNumber * 1 ether;
        payable(msg.sender).transfer(withdrawAmount);
        totalWithdrawals += withdrawAmount;
        emit Withdrawal(msg.sender, withdrawAmount);
    }

    function getUserBalance(address user) public view returns (uint) {
        return userBalances[user];
    }

    fallback() external {
        (bool success, ) = fibonacciLibrary.delegatecall(msg.data);
        require(success);
    }
}

contract FibonacciLib {
    uint public start;
    uint public calculatedFibNumber;
    uint public calculationCount;

    function setStart(uint _start) public {
        start = _start;
    }

    function setFibonacci(uint n) public {
        calculatedFibNumber = fibonacci(n);
        calculationCount++;
    }

    function fibonacci(uint n) internal returns (uint) {
        if (n == 0) return start;
        else if (n == 1) return start + 1;
        else return fibonacci(n - 1) + fibonacci(n - 2);
    }

    function getCalculationCount() public view returns (uint) {
        return calculationCount;
    }
}