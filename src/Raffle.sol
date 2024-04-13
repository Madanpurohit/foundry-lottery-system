// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
/**
 * @title Raffle Smart Contract
 * @author Madanpurohit
 * @notice
 */

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Raffle is VRFConsumerBaseV2{
    /**
     * Errors
     */
    error Raffle__notEnoughEthSent();
    error Raffle__transferFailed();
    error Raffle_raffleNotOpened();
    error Raffle__upKeepNotNeeded(
        uint256 currentBalance,
        uint256 length,
        RaffleState raffleState
    );
    /**Type Declaration */
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    /**States */
    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private constant NUM_WORD = 1;

    uint256 private immutable i_entrace_fee;
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_coordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    address payable[] private s_player;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    /**
     * Events
     */
    event EnteredRaffle(address indexed player);
    event PickedWineer(address indexed winner);

    constructor(
        uint256 entrace_fee, 
        uint256 interval, 
        address vrfCoordinator, 
        bytes32 gasLane, 
        uint64 subscriptionId,
        uint32 callbackGasLimit
        ) VRFConsumerBaseV2(vrfCoordinator){
            i_entrace_fee = entrace_fee;
            s_lastTimeStamp = block.timestamp;
            i_interval = interval;
            i_coordinator = VRFCoordinatorV2Interface(vrfCoordinator);
            i_gasLane = gasLane;
            i_subscriptionId = subscriptionId;
            i_callbackGasLimit = callbackGasLimit;
            s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entrace_fee) {
            revert Raffle__notEnoughEthSent();
        }
        if(s_raffleState == RaffleState.CALCULATING){
            revert Raffle_raffleNotOpened();
        }
        s_player.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }
    /**
     * @dev Check if contract has enough balanace
     * @dev check if Interval is correct
     * @dev Enough player is there
     * @dev Valid coordinator address is there
     * @dev Raffle state should be open 
     */
    function checkUpkeep(
        bytes memory /*checkData*/
    ) public  view returns (bool, bytes memory) {
        bool hasBalance = address(this).balance > 0;
        bool hasCorrectInterval = (s_lastTimeStamp - block.timestamp) > i_interval;
        bool hasEnoughPlayer = s_player.length > 0;
        bool isRaffleStateOpen = RaffleState.OPEN == s_raffleState;
        bool isUpKeepNeeded = (hasBalance && hasCorrectInterval && hasEnoughPlayer && isRaffleStateOpen);
        return (isUpKeepNeeded,bytes(""));
    }

    function performUpkeep(bytes calldata /*performData*/) external {
        (bool isUpKeepNeeded,) = checkUpkeep(bytes(""));
        if(!isUpKeepNeeded){
            revert Raffle__upKeepNotNeeded(
                address(this).balance,
                s_player.length,
                s_raffleState
            );
        }
        s_raffleState = RaffleState.CALCULATING;
        uint256 requestId = i_coordinator.requestRandomWords(
            i_gasLane, 
            i_subscriptionId, 
            REQUEST_CONFIRMATION, 
            i_callbackGasLimit, 
            NUM_WORD
        );
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        uint256 randomWord = _randomWords[0];
        uint256 index = _randomWords[0]%s_player.length;
        address payable winner = s_player[index];
        s_recentWinner = winner;
        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
        s_player = new address payable[](0);
        (bool success,) = winner.call{value: address(this).balance}("");
        if(!success){
            revert Raffle__transferFailed();
        }
        emit PickedWineer(winner);
    }
}
