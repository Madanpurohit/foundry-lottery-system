// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription,FundSubscription,AddConsumer} from "./Interaction.s.sol";

contract DeployRaffle is Script{
    function run() external returns (Raffle,HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
        uint256 entrace_fee, 
        uint256 interval, 
        address vrfCoordinator, 
        bytes32 gasLane, 
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        address link,
        uint256 deployKey
        ) = helperConfig.networkConfig();
        if(subscriptionId == 0){
            // We need create subscription here
            CreateSubscription createSubsription = new CreateSubscription();
            subscriptionId = createSubsription.createSubsription(vrfCoordinator,deployKey);

            // Now we gona need to fund the subcription
            FundSubscription fundSubs = new FundSubscription();
            fundSubs.fundSubscription(vrfCoordinator, subscriptionId, link,deployKey);
        }
        vm.startBroadcast(deployKey);
        Raffle raffle = new Raffle(
            entrace_fee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();
        // We need to add consumer
        AddConsumer addConsume = new AddConsumer();
        addConsume.addConsumer(vrfCoordinator, subscriptionId,address(raffle),deployKey);
        return (raffle,helperConfig);
    }
}