// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface Errors {

    error ZERO_ADDRESS_NOT_ALLOWED();
    error ZERO_VALUE_NOT_ALLOWED();
    error INVALID_TRANSACTION_ID();
    error CANNOT_SIGN_MORE_THAN_ONCE();
    error INSUFFICIENT_CONTRACT_BALANCE();
    error TRANSACTION_ALREADY_EXECUTED();
    error QUORUM_COUNT_REACHED();
    error NOT_NEXT_OWNER();
    error NOT_VALID_SIGNER();
    error SIGNER_ALREADY_EXIST();
    error ONLY_OWNER_ALLOWED();
}