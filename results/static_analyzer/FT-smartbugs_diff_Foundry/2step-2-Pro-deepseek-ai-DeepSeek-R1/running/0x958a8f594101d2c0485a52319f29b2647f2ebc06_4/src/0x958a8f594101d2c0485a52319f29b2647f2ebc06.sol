pragma solidity ^0.8.26;

contract Owned {
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public owner;
    address public newOwner;

    constructor() {
        owner = msg.sender;
    }

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

contract Marriage is Owned {
    string public partner1;
    string public partner2;
    uint public marriageDate;
    string public marriageStatus;
    string public vows;

    Event[] public majorEvents;
    Message[] public messages;

    struct Event {
        uint date;
        string name;
        string description;
        string url;
    }

    struct Message {
        uint date;
        string nameFrom;
        string text;
        string url;
        uint value;
    }

    modifier areMarried {
        require(keccak256(abi.encodePacked(marriageStatus)) == keccak256(abi.encodePacked("Married")));
        _;
    }

    constructor(address _owner) {
        owner = _owner;
    }

    function numberOfMajorEvents() public view returns (uint) {
        return majorEvents.length;
    }

    function numberOfMessages() public view returns (uint) {
        return messages.length;
    }

    function createMarriage(
        string memory _partner1,
        string memory _partner2,
        string memory _vows,
        string memory url
    ) public onlyOwner {
        require(majorEvents.length == 0);
        partner1 = _partner1;
        partner2 = _partner2;
        marriageDate = block.timestamp;
        vows = _vows;
        marriageStatus = "Married";
        majorEvents.push(Event(block.timestamp, "Marriage", vows, url));
        emit MajorEvent("Marrigage", vows, url);
    }

    function setStatus(string memory status, string memory url) public onlyOwner {
        marriageStatus = status;
        setMajorEvent("Changed Status", status, url);
    }

    function setMajorEvent(string memory name, string memory description, string memory url) public onlyOwner areMarried {
        majorEvents.push(Event(block.timestamp, name, description, url));
        emit MajorEvent(name, description, url);
    }

    function sendMessage(string memory nameFrom, string memory text, string memory url) public payable areMarried {
        if (msg.value > 0) {
            payable(owner).transfer(address(this).balance);
        }
        messages.push(Message(block.timestamp, nameFrom, text, url, msg.value));
        emit MessageSent(nameFrom, text, url, msg.value);
    }

    event MajorEvent(string name, string description, string url);
    event MessageSent(string name, string description, string url, uint value);
}