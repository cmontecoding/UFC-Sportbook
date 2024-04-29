// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {Sportsbook} from "../src/SportsbookConcept.sol";

contract SportsbookTest is Test {
    Sportsbook public sportsbook;
    address public userA;
    address public userB;

    function setUp() public {
        userA = address(0x1);
        userB = address(0x2);
        sportsbook = new Sportsbook(address(this));

        vm.deal(userA, 1000);
        vm.deal(userB, 1000);
    }

    function testSportsbook() public {
        vm.prank(userA);
        sportsbook.betA{value: 1000}();
        assertEq(sportsbook.sideA(), userA);

        vm.prank(userB);
        sportsbook.betB{value: 1000}();
        assertEq(sportsbook.sideB(), userB);

        assertEq(address(sportsbook).balance, 2000);

        sportsbook.payout(true);
        assertEq(address(userA).balance, 2000);
        assertEq(sportsbook.sideA(), address(0));
        assertEq(sportsbook.sideB(), address(0));
    }

    /// @notice make sure someone cant bet twice on the same side
    function testBetTwiceRevert() public {
        vm.prank(userA);
        sportsbook.betA{value: 1000}();
        vm.expectRevert();
        vm.prank(userA);
        sportsbook.betA{value: 1000}();
    }

    /// @notice make sure bet > 0
    function testBetZeroRevert() public {
        vm.expectRevert();
        vm.prank(userA);
        sportsbook.betA{value: 0}();
    }

    /// @notice make sure that both sides have to bet
    function testPayoutRevert() public {
        vm.prank(userA);
        sportsbook.betA{value: 1000}();
        vm.expectRevert();
        vm.prank(userA);
        sportsbook.payout(true);
    }

    /// @notice make sure that only authorized party can call payout
    function testOnlyAuthRevert() public {
        /// @dev setup betting
        vm.prank(userA);
        sportsbook.betA{value: 1000}();
        vm.prank(userB);
        sportsbook.betB{value: 1000}();

        vm.expectRevert();
        vm.prank(userA);
        sportsbook.payout(true);
    }
}