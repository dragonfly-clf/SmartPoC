pragma solidity ^0.8.26;

contract Owned {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() { if (msg.sender == owner) _; }

    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function execute(address _dst, uint _value, bytes memory _data) public onlyOwner {
        payable(_dst).call{value: _value}(_data);
    }
}

abstract contract Token {
    function transfer(address, uint) public virtual returns(bool);
    function balanceOf(address) public view virtual returns (uint);
}

contract TokenSender is Owned {
    Token public token;
    uint public totalToDistribute;
    uint public next;

    struct Transfer {
        address addr;
        uint amount;
    }

    Transfer[] public transfers;

    constructor(address _token) {
        token = Token(_token);
    }

    uint constant D160 = 0x0010000000000000000000000000000000000000000;

    function fill(uint[] memory data) public onlyOwner {
        if (next>0) revert();

        uint acc;
        uint offset = transfers.length;
        for (uint i = 0; i < data.length; i++ ) {
            unchecked {
                address addr = address( uint160(data[i] & (D160-1)) );
                uint amount = data[i] / D160;

                transfers.push(Transfer(addr, amount));
                acc += amount;
            }
        }
        unchecked {
            totalToDistribute += acc;
        }
    }

    function run() public onlyOwner {
        if (transfers.length == 0) return;

        uint mNext = next;
        next = transfers.length;

        if ((mNext == 0 ) && ( token.balanceOf(address(this)) != totalToDistribute)) revert();

        while ((mNext<transfers.length) && ( gasleft() > 150000 )) {
            uint amount = transfers[mNext].amount;
            address addr = transfers[mNext].addr;
            if (amount > 0) {
                if (!token.transfer(addr, transfers[mNext].amount)) revert();
            }
            unchecked {
                mNext++;
            }
        }

        next = mNext;
    }

    function hasTerminated() public view returns (bool) {
        if (transfers.length == 0) return false;
        if (next < transfers.length) return false;
        return true;
    }

    function nTransfers() public view returns (uint) {
        return transfers.length;
    }
}