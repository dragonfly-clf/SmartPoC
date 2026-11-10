pragma solidity ^0.8.26;

contract Delta {
    address public c = 0xF85A2E95FA30d005F629cBe6c6d2887D979ffF2A;
    address public owner = 0x788C45Dd60aE4dBE5055b5Ac02384D5dc84677b0;
    address public owner2 = 0x0C6561edad2017c01579Fd346a58197ea01A0Cf3;
    uint256 public active = 1;
    uint256 public token_price = 10**18 * 1 / 1000;

    receive() external payable {
        tokens_buy();
    }

    function tokens_buy() public payable returns (bool) {
        require(active > 0);
        require(msg.value >= token_price);

        uint256 tokensToBuy = msg.value * 10**18 / token_price;

        require(tokensToBuy > 0);

        (bool success, ) = c.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", owner, msg.sender, tokensToBuy));
        if (!success) {
            return false;
        }

        uint256 sum2 = msg.value * 3 / 10;
        payable(owner2).send(sum2);

        return true;
    }

    function withdraw(uint256 _amount) public onlyOwner returns (bool result) {
        uint256 balance;
        balance = address(this).balance;
        if (_amount > 0) balance = _amount;
        payable(owner).send(balance);
        return true;
    }

    function change_token_price(uint256 _token_price) public onlyOwner returns (bool result) {
        token_price = _token_price;
        return true;
    }

    function change_active(uint256 _active) public onlyOwner returns (bool result) {
        active = _active;
        return true;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
}