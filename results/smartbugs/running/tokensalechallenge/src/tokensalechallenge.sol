pragma solidity ^0.8.26;

contract TokenSaleChallenge {
    mapping(address => uint256) public balanceOf;
    uint256 constant PRICE_PER_TOKEN = 1 ether;
    address public owner;
    uint256 public totalTokensSold;
    uint256 public totalTokensBurned;
    
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 cost);
    event TokensSold(address indexed seller, uint256 amount, uint256 revenue);
    event TokensBurned(address indexed burner, uint256 amount);

    constructor(address _player) payable {
        require(msg.value == 1 ether);
        owner = msg.sender;
    }

    function isComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numTokens) public payable {
        unchecked {
            require(msg.value == numTokens * PRICE_PER_TOKEN);
            balanceOf[msg.sender] += numTokens;
            totalTokensSold += numTokens;
            emit TokensPurchased(msg.sender, numTokens, msg.value);
        }
    }

    function sell(uint256 numTokens) public {
        require(balanceOf[msg.sender] >= numTokens);

        unchecked {
            balanceOf[msg.sender] -= numTokens;
            payable(msg.sender).transfer(numTokens * PRICE_PER_TOKEN);
            emit TokensSold(msg.sender, numTokens, numTokens * PRICE_PER_TOKEN);
        }
    }

    function burn(uint256 numTokens) public {
        require(balanceOf[msg.sender] >= numTokens);
        
        unchecked {
            balanceOf[msg.sender] -= numTokens;
            totalTokensBurned += numTokens;
            emit TokensBurned(msg.sender, numTokens);
        }
    }

    function getTotalSupply() public view returns (uint256) {
        return totalTokensSold - totalTokensBurned;
    }
}