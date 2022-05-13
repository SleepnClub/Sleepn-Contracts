// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { ISuperfluid, ISuperToken, ISuperApp } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { IConstantFlowAgreementV1 } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";
import { CFAv1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/CFAv1Library.sol";

import "./SleepToken.sol";


contract reward is Initializable, OwnableUpgradeable {
    ISuperToken public superToken; // super token address

    ISuperfluid private host; // host
    IConstantFlowAgreementV1 private cfa; // the stored constant flow agreement class address

    using CFAv1Library for CFAv1Library.InitData;
    CFAv1Library.InitData public cfaV1; //initialize cfaV1 variable

    // Init 
    function initialize(
        ISuperToken _superToken, 
        ISuperfluid _host, 
        IConstantFlowAgreementV1 _cfa
    ) initializer public {
        superToken = _superToken;
        host = _host;
        cfa = _cfa;
        
        assert(address(superToken) != address(0));
        assert(address(host) != address(0));
        assert(address(cfa) != address(0));

        cfaV1 = CFAv1Library.InitData(
        _host,
        IConstantFlowAgreementV1(
            address(_host.getAgreementClass(
                    keccak256("org.superfluid-finance.agreements.ConstantFlowAgreement.v1")
                ))
            )
        );
    }

    // Increase the flow or create it
    function _increaseFlow(address _receiver, int96 _flowRate) internal {
        require(_receiver != address(this), "Receiver must be different than sender");

        (, int96 outFlowRate, , ) = cfa.getFlow(
            superToken,
            address(this),
            _receiver
        ); 

        if (outFlowRate == 0) {
            cfaV1.createFlow(_receiver, superToken, _flowRate);
        } else {
            cfaV1.updateFlow(_receiver, superToken, outFlowRate + _flowRate);
        }
    }

    // Reduce the flow or delete it
    function _reduceFlow(address _receiver, int96 _flowRate) internal {
        require(_receiver != address(this), "Receiver must be different than sender");

        (, int96 outFlowRate, , ) = cfa.getFlow(
            superToken,
            address(this),
            _receiver
        );

        if (outFlowRate == _flowRate) {
            cfaV1.deleteFlow(address(this), _receiver, superToken);
        } else if (outFlowRate > _flowRate) {
            cfaV1.updateFlow(_receiver, superToken, outFlowRate - _flowRate);
        }
    }


    

}