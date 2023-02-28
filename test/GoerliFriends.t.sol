// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "../src/GoerliFriends.sol";

contract GoerliFriendsTest is Test {
    GoerliFriends public gf;

    address maria = makeAddr("maria");

    event Dump(address indexed goerliFriend, uint256 amount);

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("goerli"));
        gf = new GoerliFriends();
        deal(maria, 4_000_000 ether);
    }

    function testDump() public {
        assertEq(address(gf).balance, 0);
        assertEq(maria.balance, 4_000_000 ether);

        vm.expectEmit(true, false, false, true);
        emit Dump(maria, 250_000 ether);

        vm.prank(maria);
        gf.dump{value: 250_000 ether}();

        assertEq(address(gf).balance, 0);
        assertEq(maria.balance, 3_750_000 ether);
    }

    function testReceive() public {
        assertEq(address(gf).balance, 0);
        assertEq(maria.balance, 4_000_000 ether);

        vm.expectEmit(true, false, false, true);
        emit Dump(maria, 400_000 ether);

        vm.startPrank(maria);
        payable(address(gf)).transfer(100_000 ether);
        gf.dump{value: 300_000 ether}();
        vm.stopPrank();

        assertEq(address(gf).balance, 0);
        assertEq(maria.balance, 3_600_000 ether);
    }
}
