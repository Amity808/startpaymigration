// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract WasteInsured {
    // Struct to represent waste records
    struct Waste {
        address payable wasteAdmin;
        address payable producer;
        string depositor;
        string wasteType; // Store the waste type as an integer (0 for Plastic, 1 for Metal)
        string collectionLocation;
        uint256 weight;
        bool isRecorded;
        bool isValidated;
        bool isPaid;
        uint256 wasteAmount; // Hospital ID assigned by the waste admin
        address payable hospitalAddress;
    }

    // Struct to represent information about hospitals
    struct Hospital {
        string name;
        string image;
        string location;
        string hospitalType;
        address payable walletAddress;
    }

    // Mapping to store waste records
    mapping(uint256 => Waste) public wasteRecords;
    uint256 public wasteCounter;

    // Mapping to keep track of assigned point of collection
    mapping(address => bool) public assignedCollector;

    // Address of the waste admin (previously named Collector)
    address payable public wasteAdmin;

    // Mapping to store information about hospitals
    mapping(uint256 => Hospital) public hospitals;

    uint256 public hospitalCounter; // Counter to track the number of registered hospitals

    // Events
    event WasteRecorded(uint256 indexed wasteId, address indexed producer, string depositor, string wasteType, string collectionLocation, uint256 weight, uint256 wasteAmount, address payable hospitalAddress);
    event WasteValidated(uint256 indexed wasteId, address indexed wasteAdmin);
    event PaymentSent(address indexed recipient, uint256 amount);
    event FundsWithdrawn(address indexed wasteAdmin, uint256 amount);
    event FundsDeposited(address indexed wasteAdmin, uint256 amount);
    event HospitalRegistered(uint256 indexed hospitalId, string name, string location, string hospitalType, address walletAddress);

    // Modifier to restrict access to assigned producers
    modifier onlyCollector() {
        require(assignedCollector[msg.sender], "Must be a collector");
        _;
    }

    // Modifier to restrict access to the waste admin
    modifier onlyWasteAdmin() {
        require(msg.sender == wasteAdmin, "Only the waste admin can perform this action");
        _;
    }

    // Constructor to set the waste admin during deployment
    constructor() {
        wasteAdmin = payable(msg.sender);
    }

    // Function for the waste admin to register a partnered hospital
    function registerPartnerHospital(string memory _name, string memory _image, string memory _location, string memory _hospitalType, address payable _walletAddress) public onlyWasteAdmin {
        require(_walletAddress != address(0), "Invalid hospital address");

        hospitals[hospitalCounter] = Hospital(_name, _image, _location, _hospitalType, _walletAddress);
        hospitalCounter++;
        emit HospitalRegistered(hospitalCounter, _name, _location, _hospitalType, _walletAddress);
    }

    // Function for a producer to choose a hospital based on the hospital ID
    function assignProducer(address payable _collector) public {
        require(_collector != address(0), "Invalid producer address");

        assignedCollector[_collector] = true;
    }

    // Function for a producer to record waste information
    function recordWaste(string memory _depositor, string memory _wasteType, string memory _collectionLocation, uint256 _weight, uint256 _wasteAmount, address payable _hospitalAddress) public onlyCollector {
        wasteRecords[wasteCounter++] = Waste(wasteAdmin, payable(msg.sender), _depositor, _wasteType, _collectionLocation, _weight, true, false, false, _wasteAmount, _hospitalAddress);

        emit WasteRecorded(wasteCounter, msg.sender, _depositor, _wasteType, _collectionLocation, _weight, _wasteAmount, _hospitalAddress);
    }

    // Function for the waste admin to know if the waste recorded waste is validated
    function validateWaste(uint256 _wasteId) public onlyWasteAdmin {
        require(_wasteId <= wasteCounter, "Invalid waste ID");
        require(wasteRecords[_wasteId].isRecorded, "Waste is not yet recorded");
        require(!wasteRecords[_wasteId].isValidated, "Waste is already validated");

        emit WasteValidated(_wasteId, msg.sender);
    }

    // Function for the waste admin to send payment to a hospital
    function wastePayment(uint256 _wasteId) external onlyWasteAdmin {
        require(!wasteRecords[_wasteId].isValidated, "Waste is already validated");

        wasteRecords[_wasteId].isValidated = true;
        wasteRecords[_wasteId].isPaid = true;
        uint256 amount = wasteRecords[_wasteId].wasteAmount;

        (bool sent, ) = wasteRecords[_wasteId].hospitalAddress.call{value: amount}("");
        require(sent, "Failed to send Ether");

        emit PaymentSent(wasteRecords[_wasteId].hospitalAddress, amount);
    }

    function withdrawFunds(uint256 _amount) public onlyWasteAdmin {
        require(_amount <= address(this).balance, "Insufficient contract balance");

        (bool sent, ) = wasteAdmin.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        emit FundsWithdrawn(wasteAdmin, _amount);
    }

    // Function to get waste information by waste ID
    function getWasteInfo(uint256 _wasteId) public view returns (
        address,
        address,
        string memory,
        string memory,
        string memory,
        uint256,
        bool,
        bool,
        bool,
        uint256,
        address payable
    ) {
        Waste storage waste = wasteRecords[_wasteId];

        return (
            waste.wasteAdmin,
            waste.producer,
            waste.depositor,
            waste.wasteType,
            waste.collectionLocation,
            waste.weight,
            waste.isRecorded,
            waste.isValidated,
            waste.isPaid,
            waste.wasteAmount,
            waste.hospitalAddress
        );
    }

    // Function to get the total number of registered hospitals
    function getWasteLength() public view returns (uint256) {
        return wasteCounter;
    }

    function getHospitalCount() public view returns (uint256) {
        return hospitalCounter;
    }

    // Function to get information about a specific hospital by hospital ID
    function getHospitalInfo(uint256 _hospitalId) public view returns (string memory name, string memory image, string memory location, string memory hospitalType, address walletAddress) {
        require(_hospitalId <= hospitalCounter, "Invalid hospital ID");

        Hospital storage hospital = hospitals[_hospitalId];

        return (
            hospital.name,
            hospital.image,
            hospital.location,
            hospital.hospitalType,
            hospital.walletAddress
        );
    }

    // Fallback function to receive funds
    receive() external payable {}
}
