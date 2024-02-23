// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./Errors.sol";


contract MultiSig {
    address private owner;
    address private nextOwner;

    address[] private signers;
    uint8 private quorum;
    uint8 private txCount;

    struct Transaction {
        uint256 id;
        uint256 amount;
        address receiver;
        uint256 signersCount;
        bool isExecuted;
        address txCreator;
    }

    Transaction[] private allTransactions;

    // mapping of transaction id to signer address returning bool:
    // this checks if a valid signer has signed a transaction
    mapping (uint256 => mapping (address => bool)) private hasSigned;

    // mapping of transaction id to transaction struct
    // used to track transactions given their ID;
    mapping(uint256 => Transaction) private transactions;

    mapping(address => bool) private isValidSigner;


    constructor(address[] memory _validSigners) {
        address _owner = msg.sender;
        owner = _owner;

        //this is to set all signers into a map
        for(uint8 i = 0; i < _validSigners.length; i++) {
            if (_validSigners[i] == address(0)) {
                continue;
            }
            isValidSigner[_validSigners[i]] = true;
            signers.push(_validSigners[i]);
        }

        //this is to make the owner also a signer
        signers.push(_owner);
        isValidSigner[_owner] = true;

        //this sets the quorum to 75$ of the signers
       quorum = uint8((signers.length * 75) / 100);
    }

    function initiateTransaction(uint256 _amount, address _receiver) external {
        if (msg.sender == address(0)) revert Errors.ZERO_ADDRESS_NOT_ALLOWED();
        if (_amount <= 0) revert Errors.ZERO_VALUE_NOT_ALLOWED();

        onlyValidSigner();

        uint256 _txId = txCount + 1;

        Transaction storage tns = transactions[_txId];

        tns.id = _txId;
        tns.amount = _amount;
        tns.receiver = _receiver;
        tns.signersCount = tns.signersCount + 1;
        tns.txCreator = msg.sender;

        allTransactions.push(tns);

        hasSigned[_txId][msg.sender] = true;

        txCount = txCount + 1;
    }

    function approveTransaction(uint256 _txId) external {
        if (_txId > txCount) revert Errors.INVALID_TRANSACTION_ID();
        if (msg.sender == address(0)) revert Errors.ZERO_ADDRESS_NOT_ALLOWED();

        onlyValidSigner();

        if (hasSigned[_txId][msg.sender]) revert Errors.CANNOT_SIGN_MORE_THAN_ONCE();

        Transaction storage tns = transactions[_txId];
        if (address(this).balance < tns.amount) revert Errors.INSUFFICIENT_CONTRACT_BALANCE();

        if (tns.isExecuted) revert Errors.TRANSACTION_ALREADY_EXECUTED();
        if (tns.signersCount >= quorum) revert Errors.QUORUM_COUNT_REACHED();

        tns.signersCount = tns.signersCount + 1;

        hasSigned[_txId][msg.sender] = true;

        if(tns.signersCount == quorum) {
            tns.isExecuted = true;
            payable(tns.receiver).transfer(tns.amount);
        }
    }

    function transferOwnership(address _newOwner) external {
        onlyOwner();
        nextOwner = _newOwner;
    }

    function claimOwnership() external {
        if (msg.sender != nextOwner) revert Errors.NOT_NEXT_OWNER();

        owner = msg.sender;

        nextOwner = address(0);
    }

    function addValidSigner(address _newSigner) external {
        onlyOwner();

        if (isValidSigner[_newSigner]) revert Errors.SIGNER_ALREADY_EXIST();

        isValidSigner[_newSigner] = true;
        signers.push(_newSigner);

        //75% of the total signers
        quorum = uint8((signers.length * 75) / 100);
    }

    function getAllTransactions() external view returns (Transaction[] memory) {
        return allTransactions;
    }

    function onlyOwner() private view {
        if (msg.sender != owner) revert Errors.ONLY_OWNER_ALLOWED();
    }

    function onlyValidSigner() private view {
        if (!isValidSigner[msg.sender]) revert Errors.NOT_VALID_SIGNER();
    }

    function getAllSigners() external view returns (address[] memory) {
        return signers;
    }

    receive() external payable {}

    fallback() external payable {}
}