//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomWinnerGame is VRFConsumerBase, Ownable {
    //amount of Link to send with request
    uint256 public fee;

    //ID of puclic key against which the randomness is generated
    bytes32 public keyHash;

    //addresses of the players of the game
    address[] public players;
    //maximum number of players
    uint8 maxPlayers;
    bool public gameStarted;
    //fee for entering the game
    uint256 entryFee;
    //ID of the game
    uint256 public gameId;

    //event emitted when the game starts
    event GameStarted(uint256 gameId, uint8 maxPlayers, uint256 entryFee);

    //emitted when someone joins the game
    event PlayerJoined(uint256 gameId, address player);

    //emitted when the game ends
    event GameEnded(uint256 gameId, address winner, bytes32 requestId);

    //constructor inherits VRFConsumetBase contract and initiates it some parameters

    constructor(
        address vrfCoordinator,
        address linkToken,
        bytes32 vrfKeyHash,
        uint256 vrfFee
    ) VRFConsumerBase(vrfCoordinator, linkToken) {
        keyHash = vrfKeyHash;
        fee = vrfFee;
        gameStarted = false;
    }

    //starts the game by setting appropriate values for all the parameters
    function startGame(uint8 _maxPlayers, uint256 _entryFee) public onlyOwner {
        //check if the game is already running
        require(!gameStarted, "Game is currently running");
        //empty the players array
        delete players;
        //set the max players for this game
        maxPlayers = _maxPlayers;
        gameStarted = true;
        entryFee = _entryFee;
        gameId += 1;
        emit GameStarted(gameId, maxPlayers, entryFee);
    }

    //called when the player wants to enter the game
    function joinGame() public payable {
        require(gameStarted, "Game has not started yet");
        require(msg.value == entryFee, "Value sent is not equal to entry fee");
        require(players.length < maxPlayers, "No more spaces for new players");
        //add the sender to the players list
        players.push(msg.sender);
        emit PlayerJoined(gameId, msg.sender);
        //if the list is full, start the winner selection process
        if (players.length == maxPlayers) {
            getRandomWinner();
        }
    }

    /**
     * function is called by VRFCoordinator contracts when it receives a valid VRF proof
     */

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        virtual
        override
    {
        //calculate the winning number
        uint256 winnerIndex = randomness % players.length;
        //get the addres of the winned
        address winner = players[winnerIndex];
        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "Failed to send the funds to the winner");
        emit GameEnded(gameId, winner, requestId);
        gameStarted = false;
    }

    //called to start the process of selecting the winner
    function getRandomWinner() private returns (bytes32 requestId) {
        //chech that there is enough Link tokens in this contract
        require(LINK.balanceOf(address(this)) >= fee, "Not enough Link");
        return requestRandomness(keyHash, fee);
    }

    receive() external payable {}

    fallback() external payable {}
}
