// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployRaffle is Script{
    function run() external returns (Raffle) {
        HelperConfig helperConfig = new HelperConfig();
        (
        uint256 entrace_fee, 
        uint256 interval, 
        address vrfCoordinator, 
        bytes32 gasLane, 
        uint64 subscriptionId,
        uint32 callbackGasLimit
        ) = helperConfig.networkConfig();
        vm.startBroadcast();
        Raffle raffle = new Raffle(
            entrace_fee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();
        return raffle;
    }
}