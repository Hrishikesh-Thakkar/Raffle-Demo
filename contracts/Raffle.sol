// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
//interface plus address equals contract
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

//custom errors cost less than require messages to post on chain.
error Raffle_SendMoreToEnterRaffle();
error Raffle_RaffleNotOpen();
error Raffle_UpkeepNotNeeded();
error Raffle_TransferFailed();

contract Raffle is VRFConsumerBaseV2 {
    enum RaffleState {
       Open,
       Calculating 
    }

    //s_ implies it's a storage variable and expensive to work with as we will be updating it's value;
    RaffleState public s_raffleState;

    //immutable means after declared once it's constant unchangeable, it takes much less gasFee, we prefix variable with i_ to denote this.
    uint256 public immutable i_entranceFee;
    uint256 public immutable i_interval;
    VRFCoordinatorV2Interface public immutable i_vrfCoordinator;
    //address and address payable are two flavours of address data type. Address payable has additional members, i.e transfer and send.
    address payable[] public s_players;
    uint256 public s_lastTimeStamp;
    bytes32 public immutable i_gasLane;
    uint64 public immutable i_subscriptionId;
    uint32 public immutable i_callbackGasLimit;
    address public s_recentWinner; 
    uint16 public constant REQUEST_CONFIRMATIONS = 3;
    uint32 public constant NUM_WORDS = 1;

    event RaffleEnter(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    constructor(
        uint256 entranceFee,
        uint256 interval, 
        address vrfCoordinatorV2,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
        ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }
    
    function enterRaffle() external payable {
        // We typically don't use require as it takes lots of gasFee
        // require(msg.value > i_entranceFee, "Not Enough Money Sent!");
        if(msg.value < i_entranceFee){
            revert Raffle_SendMoreToEnterRaffle();
        }

        //Open, Calculating a winner
        if(s_raffleState != RaffleState.Open) {
            revert Raffle_RaffleNotOpen();
        }

        //You can enter raffle
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
    }

    // We want random winner selected randomly and automatically (Use Chainlink Keepers)

    //1. We want this to be true after some interval
    //2. The lottery to be open
    //3. Contract has ETH
    //4. Keepers has LINK
    function checkUpKeep(
        bytes memory /*checkData*/ 
    ) public view returns(
        bool upkeepNeeded,
        bytes memory /* performData */) 
    {
        bool isOpen = RaffleState.Open == s_raffleState;
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = (timePassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded,"0x0");
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external {
        (bool upkeepNeeded, ) = checkUpKeep("");
        if(!upkeepNeeded) {
            revert Raffle_UpkeepNotNeeded();
        }
        s_raffleState = RaffleState.Calculating;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit RequestedRaffleWinner(requestId);
    }

    function fulfillRandomWords(
        uint256,
        uint256[] memory randomWords
        //it is internal override because the chainlink coordinator contract needs to validate if these words are random first
        //That contract is supposed to call this fulfillRandomwords function.
        //For that we need to make our contract compatible with it.
    ) internal override{
        uint256 indexOfWinner = randomWords[0]%s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_players = new address payable[](0);
        s_raffleState = RaffleState.Open;
        s_lastTimeStamp = block.timestamp;
        //best way to send money
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if(!success){
            revert Raffle_TransferFailed();
        }
        emit WinnerPicked(recentWinner);
    }
}