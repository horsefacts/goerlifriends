// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "forge-std/Script.sol";
import "../src/GoerliFriends.sol";

contract DeployGoerliFriends is Script {
    function run() public {
        vm.broadcast();
        new GoerliFriends();
    }
}
