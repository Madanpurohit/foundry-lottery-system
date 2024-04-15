// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script,console} from 'forge-std/Script.sol';
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract CreateSubscription is Script{

    function createSubsription(address vrfCoordinator,uint256 deployKey) external returns(uint64){
        console.log("Creating subsription for chainLink");
        vm.startBroadcast(deployKey);
        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Subscription has been created",subId);
        return subId;
    }
}

contract FundSubscription is Script{
    uint96 private constant INTIAL_FUNDING_AMOUNT = 3 ether;
    function fundSubscription(address vrfCoordinator,uint64 subId, address link,uint256 deployerKey) external{
        console.log("Funding the contract");
        console.log("Chainid is ",block.chainid);
        console.log("Vrfcoordinor is ",vrfCoordinator);
        if(block.chainid == 31337){
            //It will fund anvil
            vm.startBroadcast(deployerKey);
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(subId,INTIAL_FUNDING_AMOUNT);
            vm.stopBroadcast();
        } else{
            // It will fund Sapolia
            vm.startBroadcast();
            LinkToken(link).transferAndCall(
                vrfCoordinator,
                INTIAL_FUNDING_AMOUNT,
                abi.encode(subId)
            );
            vm.stopBroadcast();
        }
    }
}

contract AddConsumer is Script{
    function addConsumer(address vrfCoordinator,uint64 subId,address consumerAddress,uint256 deployerKey) external{
        console.log("Adding Consumer");
        console.log("Chainid is ",block.chainid);
        console.log("Vrfcoordinor is ",vrfCoordinator);
        vm.startBroadcast(deployerKey);
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(subId,consumerAddress);
        vm.stopBroadcast();
    }
}