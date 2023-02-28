// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "../src/GoerliFriends.sol";

contract GoerliFriendsTest is Test {
    GoerliFriends public gf;

    address maria = makeAddr("maria");
    address horsefacts = makeAddr("horsefacts");

    event Dump(address indexed caller, uint256 amount);
    event Contribute(address indexed goerliFriend, uint256 amount);

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("goerli"));
        gf = new GoerliFriends();
        deal(maria, 4_000_000 ether);
        deal(horsefacts, 10 ether);
    }

    function testDumpAboveMinimumAmount() public {
        assertEq(address(gf).balance, 0);
        assertEq(maria.balance, 4_000_000 ether);

        vm.expectEmit(true, false, false, true);
        emit Contribute(maria, 250_000 ether);

        vm.expectEmit(true, false, false, true);
        emit Dump(maria, 250_000 ether);

        vm.prank(maria);
        gf.dump{value: 250_000 ether}();

        assertEq(address(gf).balance, 0);
        assertEq(maria.balance, 3_750_000 ether);
    }

    function testDumpBelowMinimumAmount() public {
        assertEq(address(gf).balance, 0);
        assertEq(horsefacts.balance, 10 ether);

        vm.expectEmit(true, false, false, true);
        emit Contribute(horsefacts, 10 ether);

        vm.prank(horsefacts);
        gf.dump{value: 10 ether}();

        assertEq(address(gf).balance, 10 ether);
        assertEq(horsefacts.balance, 0 ether);
    }

    function testReceiveContribution() public {
        assertEq(address(gf).balance, 0);
        assertEq(horsefacts.balance, 10 ether);

        vm.expectEmit(true, false, false, true);
        emit Contribute(horsefacts, 10 ether);

        vm.prank(horsefacts);
        payable(address(gf)).transfer(10 ether);

        assertEq(address(gf).balance, 10 ether);
        assertEq(horsefacts.balance, 0 ether);
    }

    function testReceive() public {
        assertEq(address(gf).balance, 0);
        assertEq(maria.balance, 4_000_000 ether);

        vm.expectEmit(true, false, false, true);
        emit Contribute(maria, 100_000 ether);

        vm.expectEmit(true, false, false, true);
        emit Contribute(maria, 300_000 ether);

        vm.expectEmit(true, false, false, true);
        emit Dump(maria, 400_000 ether);

        vm.startPrank(maria);
        payable(address(gf)).transfer(100_000 ether);
        gf.dump{value: 300_000 ether}();
        vm.stopPrank();

        assertEq(address(gf).balance, 0);
        assertEq(maria.balance, 3_600_000 ether);
    }

    function testReceiveContributeSwap() public {
        assertEq(address(gf).balance, 0);
        assertEq(maria.balance, 4_000_000 ether);
        assertEq(horsefacts.balance, 10 ether);

        vm.expectEmit(true, false, false, true);
        emit Contribute(horsefacts, 5 ether);

        vm.prank(horsefacts);
        payable(address(gf)).transfer(5 ether);

        vm.expectEmit(true, false, false, true);
        emit Contribute(horsefacts, 5 ether);

        vm.prank(horsefacts);
        gf.dump{value: 5 ether}();

        vm.expectEmit(true, false, false, true);
        emit Contribute(maria, 100_000 ether);

        vm.expectEmit(true, false, false, true);
        emit Dump(maria, 100_010 ether);

        vm.prank(maria);
        gf.dump{value: 100_000 ether}();

        assertEq(address(gf).balance, 0);
        assertEq(horsefacts.balance, 0 ether);
        assertEq(maria.balance, 3_900_000 ether);
    }
}
