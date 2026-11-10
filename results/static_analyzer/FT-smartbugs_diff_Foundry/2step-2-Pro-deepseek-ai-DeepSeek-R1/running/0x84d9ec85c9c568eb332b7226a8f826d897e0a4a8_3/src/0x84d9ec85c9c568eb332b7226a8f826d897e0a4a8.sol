pragma solidity ^0.8.26;

contract Owned {
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    address public newOwner;

    function changeOwner(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }

    function execute(address _dst, uint _value, bytes memory _data) public onlyOwner {
        (bool success, ) = _dst.call{value: _value}(_data);
    }
}

contract WedIndex is Owned {
    string public wedaddress;
    string public partnernames;
    uint public indexdate;
    uint public weddingdate;
    uint public displaymultisig;

    IndexArray[] public indexarray;

    struct IndexArray {
        uint indexdate;
        string wedaddress;
        string partnernames;
        uint weddingdate;
        uint displaymultisig;
    }
    
    function numberOfIndex() public view returns (uint) {
        return indexarray.length;
    }

    function writeIndex(uint, string memory wedaddress, string memory partnernames, uint weddingdate, uint displaymultisig) public {
        indexarray.push(IndexArray(block.timestamp, wedaddress, partnernames, weddingdate, displaymultisig));
        emit IndexWritten(block.timestamp, wedaddress, partnernames, weddingdate, displaymultisig);
    }

    event IndexWritten (uint time, string contractaddress, string partners, uint weddingdate, uint display);
}