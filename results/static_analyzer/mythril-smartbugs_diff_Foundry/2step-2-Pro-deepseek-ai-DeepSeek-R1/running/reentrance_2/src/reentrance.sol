pragma solidity ^0.8.26;

contract Reentrance {

  mapping(address => uint) public balances;
  uint public totalDonations;
  uint public totalWithdrawals;
  mapping(address => uint) public donationCount;

  constructor() {
  }

  function donate(address _to) public payable {
    require(msg.value > 0, "Donation must be greater than 0");
    unchecked {
      balances[_to] += msg.value;
    }
    totalDonations += msg.value;
    donationCount[msg.sender]++;
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      // <yes> <report> REENTRANCY
      (bool success, ) = msg.sender.call{value: _amount}("");
      if(success) {
        _amount;
      }
      unchecked {
        balances[msg.sender] -= _amount;
      }
      totalWithdrawals += _amount;
    }
  }

  function getTotalActivity() public view returns (uint donations, uint withdrawals) {
    return (totalDonations, totalWithdrawals);
  }

  receive() external payable {}
}