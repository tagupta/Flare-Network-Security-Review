// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {
    IFdcVerification,
    IPayment,
    IBalanceDecreasingTransaction,
    IConfirmedBlockHeightExists,
    IReferencedPaymentNonexistence,
    IAddressValidity
} from "@flarenetwork/flare-periphery-contracts/flare/IFdcVerification.sol";
import {AssetManagerSettings} from "../../userInterfaces/data/AssetManagerSettings.sol";
import {Globals} from "./Globals.sol";

//@note An off-chain service (like an agent's backend) gathers data from a foreign chain (e.g., a Bitcoin transaction).
//It creates a cryptographic proof and requests the State Connector to attest to it.
//Once attested, the proof is passed to the FAssets contract.
//The FAssets contract uses this library to call fdcVerification.verifyX(_proof).
// The FDC precompile checks the proof against the State Connector's consensus data. If valid, the function returns true, and the FAssets contract can trust that the external event really happened.
library TransactionAttestation {
    // payment status constants
    uint8 internal constant PAYMENT_SUCCESS = 0;
    uint8 internal constant PAYMENT_FAILED = 1;
    uint8 internal constant PAYMENT_BLOCKED = 2;

    error PaymentFailed();
    error InvalidChain();
    error LegalPaymentNotProven();
    error TransactionNotProven();
    error BlockHeightNotProven();
    error NonPaymentNotProven();
    error AddressValidityNotProven();

    function verifyPaymentSuccess(IPayment.Proof calldata _proof) internal view {
        require(_proof.data.responseBody.status == PAYMENT_SUCCESS, PaymentFailed());
        verifyPayment(_proof);
    }

    //@note Did an agent actually send BTC to a user's Bitcoin address? (
    function verifyPayment(IPayment.Proof calldata _proof) internal view {
        AssetManagerSettings.Data storage _settings = Globals.getSettings();
        IFdcVerification fdcVerification = IFdcVerification(_settings.fdcVerification);
        require(_proof.data.sourceId == _settings.chainId, InvalidChain());
        require(fdcVerification.verifyPayment(_proof), LegalPaymentNotProven());
    }

    //@note Did an agent's Bitcoin wallet balance decrease by a certain amount?
    function verifyBalanceDecreasingTransaction(IBalanceDecreasingTransaction.Proof calldata _proof) internal view {
        AssetManagerSettings.Data storage _settings = Globals.getSettings();
        IFdcVerification fdcVerification = IFdcVerification(_settings.fdcVerification);
        require(_proof.data.sourceId == _settings.chainId, InvalidChain());
        require(fdcVerification.verifyBalanceDecreasingTransaction(_proof), TransactionNotProven());
    }

    function verifyConfirmedBlockHeightExists(IConfirmedBlockHeightExists.Proof calldata _proof) internal view {
        AssetManagerSettings.Data storage _settings = Globals.getSettings();
        IFdcVerification fdcVerification = IFdcVerification(_settings.fdcVerification);
        require(_proof.data.sourceId == _settings.chainId, InvalidChain());
        require(fdcVerification.verifyConfirmedBlockHeightExists(_proof), BlockHeightNotProven());
    }

    function verifyReferencedPaymentNonexistence(IReferencedPaymentNonexistence.Proof calldata _proof) internal view {
        AssetManagerSettings.Data storage _settings = Globals.getSettings();
        IFdcVerification fdcVerification = IFdcVerification(_settings.fdcVerification);
        require(_proof.data.sourceId == _settings.chainId, InvalidChain());
        require(fdcVerification.verifyReferencedPaymentNonexistence(_proof), NonPaymentNotProven());
    }

    //@note Does a specific address exist on a foreign chain?
    function verifyAddressValidity(IAddressValidity.Proof calldata _proof) internal view {
        AssetManagerSettings.Data storage _settings = Globals.getSettings();
        IFdcVerification fdcVerification = IFdcVerification(_settings.fdcVerification);
        require(_proof.data.sourceId == _settings.chainId, InvalidChain());
        require(fdcVerification.verifyAddressValidity(_proof), AddressValidityNotProven());
    }
}
