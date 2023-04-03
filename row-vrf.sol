// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import "./interfaces/Itreasury.sol";

contract RageOnWheelsVRF is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;
    ITreasury treasury;

    // https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    address link_token_contract = 0x404460C6A5EdE2D891e8297795264fDe62ADBB75;
    bytes32 keyHash =
        0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7;

    uint32 callbackGasLimit = 1000000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 500;

    // Storage parameters
    uint64 public s_subscriptionId = 747;

    event Randomness(uint256[] nums);

    constructor(address _treasury) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link_token_contract);
        treasury = ITreasury(_treasury);
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords() external onlyOperator {
        // Will revert if subscription is not set and funded.
        COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function changeStats(uint32 gas, uint16 amount) public onlyAdmin {
        callbackGasLimit = gas;
        numWords = amount;
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        uint256[] memory emitArray = new uint256[](randomWords.length);
        for(uint256 i = 0; i < randomWords.length; i++) {
            emitArray[i] = randomWords[i] % 101;
        }
        emit Randomness(emitArray);
    }

    modifier onlyAdmin() {
        require(treasury.isAdmin(msg.sender), "Caller is not admin");
        _;
    }

    modifier onlyOperator() {
        require(treasury.isOperator(msg.sender), "Caller is not operator");
        _;
    }
}
