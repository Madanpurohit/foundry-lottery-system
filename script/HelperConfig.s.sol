// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract HelperConfig is Script{
    struct NetworkConfig{
        uint256 entrace_fee;
        uint256 interval;
        address vrfCoordinator; 
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
    }
    NetworkConfig public networkConfig;

    constructor(){
        if(block.chainid == 11155111){
            networkConfig = getSapoliaEthConfig();
        } else{
            networkConfig = getOrCreateAnvilConfig();
        }
    }
    
    function getSapoliaEthConfig() internal pure returns(NetworkConfig memory){
        return NetworkConfig(
            {
                entrace_fee: 0.01 ether,
                interval: 30,
                vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,// Gas fee
                callbackGasLimit: 40000,//40,000
                subscriptionId: 0 //TO-DO
            }
        );
    }

    function getOrCreateAnvilConfig() internal returns(NetworkConfig memory){
        if(networkConfig.vrfCoordinator != address(0)){
            return networkConfig;
        }
        uint96 _baseFee = 0.3 ether; //0.3 link
        uint96 _gasPriceLink = 1e9; //1 gwei link
        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorV2Mock = new VRFCoordinatorV2Mock(_baseFee,_gasPriceLink);
        vm.stopBroadcast();
        return NetworkConfig(
            {
                entrace_fee: 0.01 ether,
                interval: 30,
                vrfCoordinator: address(vrfCoordinatorV2Mock),
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,// Gas fee
                callbackGasLimit: 40000,//40,000
                subscriptionId: 0 //TO-DO
            }
        );
    }
}