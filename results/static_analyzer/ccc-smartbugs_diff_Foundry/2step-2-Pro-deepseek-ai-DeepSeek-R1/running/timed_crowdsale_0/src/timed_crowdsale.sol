pragma solidity ^0.8.26;

contract TimedCrowdsale {
    uint256 public totalContributions;
    mapping(address => uint256) public contributions;
    address public owner;
    
    event ContributionMade(address indexed contributor, uint256 amount);
    event SaleFinished();

    constructor() {
        owner = msg.sender;
    }

    function isSaleFinished() public view returns (bool) {
        unchecked {
            return block.timestamp >= 1546300800;
        }
    }

    function contribute() external payable {
        require(!isSaleFinished(), "Sale has finished");
        require(msg.value > 0, "Contribution must be greater than 0");
        
        contributions[msg.sender] += msg.value;
        totalContributions += msg.value;
        
        emit ContributionMade(msg.sender, msg.value);
    }

    function withdrawFunds() external {
        require(msg.sender == owner, "Only owner can withdraw");
        require(isSaleFinished(), "Sale not finished yet");
        
        payable(owner).transfer(address(this).balance);
        emit SaleFinished();
    }
}