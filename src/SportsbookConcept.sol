// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

/// @title Sportsbook Proof Of Concept
/// @author andrewcmonte
/// @notice A simple sportsbook contract that allows two parties to bet on a side
/// and an authorized party to payout the winner
contract Sportsbook {

    address public immutable authorized;
    address public sideA;
    address public sideB;

    modifier onlyAuth() {
        require(msg.sender == authorized, "Sportsbook: unauthorized");
        _;
    }

    constructor(address _authorized) {
        authorized = _authorized;
    }

    /// @notice Bet on side A
    function betA() public payable {
        require(sideA == address(0), "Sportsbook: side A already bet");
        require(msg.value > 0, "Sportsbook: must bet more than 0");
        sideA = msg.sender;
    }

    /// @notice Bet on side B
    function betB() public payable {
        require(sideB == address(0), "Sportsbook: side B already bet");
        require(msg.value > 0, "Sportsbook: must bet more than 0");
        sideB = msg.sender;
    }

    /// @notice authorized party can payout to the winner
    function payout(bool sideAWon) public onlyAuth {
        require(sideA != address(0) && sideB != address(0), "Sportsbook: both sides must bet");
        if (sideAWon) {
            ///@dev payout side A
            (bool sent, ) = sideA.call{value: address(this).balance}("");
            require(sent, "Failed to send Ether");
        } else {
            ///@dev payout side B
            (bool sent, ) = sideB.call{value: address(this).balance}("");
            require(sent, "Failed to send Ether");
        }
        /// @dev reset the sides
        sideA = address(0);
        sideB = address(0);
    }

}