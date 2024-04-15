// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    event EnteredRaffle(address indexed player);
    address player = makeAddr("player1");
    uint256 constant INTIAL_BALANCE = 10 ether;
    Raffle raffle;
    HelperConfig helperConfig;
    uint256 entrace_fee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link;
    uint256 deployKey;

    function setUp() public {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.run();
        (
            entrace_fee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            link,
            deployKey
        ) = helperConfig.networkConfig();
        vm.deal(player, INTIAL_BALANCE);
    }

    //////////////////////////////////////////////////////////
    ///////////////////EnterRaffle///////////////////////////
    ////////////////////////////////////////////////////////

    function testRaffleIntializesInOpenState() external view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testShouldRevertWhenValueLessThenIntialValue() external {
        vm.expectRevert();
        vm.prank(player);
        raffle.enterRaffle{value: entrace_fee - 1}();
    }

    function testShouldEmitTheEvent() external {
        vm.prank(player);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(player);
        raffle.enterRaffle{value: entrace_fee}();
    }

    function testShouldFailIfRaffleIsNotInOpenState() external {
        vm.prank(player);
        raffle.enterRaffle{value: entrace_fee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");
        vm.expectRevert();
        vm.prank(player);
        raffle.enterRaffle{value: entrace_fee}();
    }

    function testAbleToEnterInRaffle() external {
        vm.prank(player);
        raffle.enterRaffle{value: entrace_fee}();
        assert(raffle.getPlayer(0) == player);
    }

    //////////////////////////////////////////////////////////
    ///////////////////TestPerformUpKey///////////////////////////
    ////////////////////////////////////////////////////////

    function testShouldrevertIfEnoughBalanceIsNotThere() external {
        
    }
}
