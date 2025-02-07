//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract MinimalAccount is IAccount, Ownable {

    error MinimalAccount__NotFromEntryPoint();
    error MinimalAccount__NotFromEntryPointOrOwner();
    error MinimalAccount__ExternalExecutionFailed(bytes _result);

    IEntryPoint immutable i_entryPoint ;

    modifier requireFromEntryPoint() {
        if (msg.sender != address(i_entryPoint)) {
            revert MinimalAccount__NotFromEntryPoint();
        }
        _;
    }

    modifier requireFromEntryPointOrOwner () {
        if(msg.sender != owner() && msg.sender != address(i_entryPoint)) {
            revert MinimalAccount__NotFromEntryPointOrOwner();
        }
        _;
    }


    constructor(address _entryPoint) Ownable(msg.sender) {
        i_entryPoint = IEntryPoint(_entryPoint);
    }

    receive() external payable{}


    function execute(address _dest, uint256 _val, bytes calldata _functionCallData) external requireFromEntryPointOrOwner {
        (bool success, bytes memory result) = payable(_dest).call{value: _val}(_functionCallData);

        if(!success) {
            revert MinimalAccount__ExternalExecutionFailed(result);
        }
    }
    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external requireFromEntryPoint
        returns (uint256 validationData)
    {
       validationData = _validateSignature(userOp, userOpHash);
        _payAccountFunds(missingAccountFunds);
    }

    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash) internal view returns (uint256) {

        bytes32 messageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        address signer = ECDSA.recover(messageHash, userOp.signature);
        if (signer != owner()) {
            return SIG_VALIDATION_FAILED;
        } else {
            return SIG_VALIDATION_SUCCESS;
        }
    }

    function _payAccountFunds(uint256 _missingAccountFunds) internal {
        
        if (_missingAccountFunds != 0) {
           (bool success,) = payable(msg.sender).call{value: _missingAccountFunds, gas: type(uint256).max}("");
           (success);
        }
    }


    function getEntryPoint() external view  returns (address) {
        return address(i_entryPoint);
    }

}


