pragma solidity ^0.8.26;

contract NameRegistrar {

    bool public unlocked = false;  // registrar locked, no name updates

    struct NameRecord { // map hashes to addresses
        bytes32 name;
        address mappedAddress;
    }

    mapping(address => NameRecord) public registeredNameRecord; // records who registered names
    mapping(bytes32 => address) public resolve; // resolves hashes to addresses
    mapping(address => uint) public registrationCount;
    uint public totalRegistrations;
    uint public registrationFee = 0.001 ether;

    event NameRegistered(address indexed registrant, bytes32 name, address mappedAddress);

    function register(bytes32 _name, address _mappedAddress) public payable {
        require(msg.value == registrationFee, "Incorrect registration fee");
        
        // set up the new NameRecord
        // <yes> <report> OTHER - uninitialized storage
        NameRecord storage newRecord = registeredNameRecord[msg.sender];
        newRecord.name = _name;
        newRecord.mappedAddress = _mappedAddress;

        resolve[_name] = _mappedAddress;
        registeredNameRecord[msg.sender] = newRecord;

        registrationCount[msg.sender]++;
        totalRegistrations++;

        require(unlocked); // only allow registrations if contract is unlocked
        
        emit NameRegistered(msg.sender, _name, _mappedAddress);
    }

    function setRegistrationFee(uint _fee) public {
        registrationFee = _fee;
    }

    function withdrawFees() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}