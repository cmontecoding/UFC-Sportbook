// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Sportsbook is ERC1155, Ownable {
    uint256 public constant SIDE_A = 0;
    uint256 public constant SIDE_B = 1;

    uint256 public sideAValue;
    uint256 public sideBValue;
    uint256 public totalValue;
    bool public sideAWon;
    Status public currentStatus;

    enum Status {
        BETTINGACTIVE,
        BETTINGCLOSED,
        WINNERDETERMINED,
        CANCELLED
    }

    constructor() ERC1155("https://api.sportsbook.com/token/{id}.json") Ownable(msg.sender) {}

    function betA() public payable {
        require(currentStatus == Status.BETTINGACTIVE, "Sportsbook: Betting is not active");
        require(msg.value > 0, "Sportsbook: must bet more than 0");
        sideAValue += msg.value;
        totalValue += msg.value;
        _mint(msg.sender, SIDE_A, msg.value, "");
    }

    function betB() public payable {
        require(currentStatus == Status.BETTINGACTIVE, "Sportsbook: Betting is not active");
        require(msg.value > 0, "Sportsbook: must bet more than 0");
        sideBValue += msg.value;
        totalValue += msg.value;
        _mint(msg.sender, SIDE_B, msg.value, "");
    }

    function closeBetting() public onlyOwner {
        require(currentStatus == Status.BETTINGACTIVE, "Sportsbook: Betting is not active");
        require(totalValue > 0, "Sportsbook: No bets placed");
        require(sideAValue > 0 && sideBValue > 0, "Sportsbook: Both sides must have bets placed");
        currentStatus = Status.BETTINGCLOSED;
    }

    function determineWinner(bool _sideAWon) public onlyOwner {
        require(currentStatus == Status.BETTINGCLOSED, "Sportsbook: Betting is not closed");
        currentStatus = Status.WINNERDETERMINED;
        sideAWon = _sideAWon;
    }

    function cancel() public onlyOwner {
        require(currentStatus != Status.WINNERDETERMINED, "Sportsbook: Winner already determined");
        currentStatus = Status.CANCELLED;
        //todo maybe return funds to bettors
    }

    function claimPayout() public {
        require(currentStatus == Status.WINNERDETERMINED, "Sportsbook: Winner not determined");
        uint256 payout = 0;
        if (sideAWon) {
            payout = (balanceOf(msg.sender, SIDE_A) * totalValue) / sideAValue;
        } else {
            payout = (balanceOf(msg.sender, SIDE_B) * totalValue) / sideBValue;
        }
        require(payout > 0, "Sportsbook: No payout available");
        payable(msg.sender).transfer(payout);
    }
}
