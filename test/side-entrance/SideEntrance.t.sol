// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Utilities} from "test/utils/Utilities.sol";
import "forge-std/Test.sol";

import  "src/side-entrance/SideEntranceLenderPool.sol";
import {Attacker} from "src/side-entrance/Attacker.sol";

contract SideEntrance is Test {
    uint256 public constant ETHER_IN_POOL = 1_000e18;

    Utilities internal utils;
    SideEntranceLenderPool public sideEntranceLenderPool;
    uint256 public attackerInitialEthBalance;
    Attacker public attacker;
    address player = makeAddr("hacker");

    function setUp() public {
        attacker = new Attacker(address(sideEntranceLenderPool));
        utils = new Utilities();

        vm.deal(player, 1e18);

        sideEntranceLenderPool = new SideEntranceLenderPool();
        vm.label(address(sideEntranceLenderPool), "Side Entrance Lender Pool");

        vm.deal(address(sideEntranceLenderPool), ETHER_IN_POOL);

        assertEq(address(sideEntranceLenderPool).balance, ETHER_IN_POOL);

        attackerInitialEthBalance = address(player).balance;

        console.log(unicode"🧨 Let's see if you can break it... 🧨");
    }

    function testExploitSideEntrance() public {
        vm.startPrank(player);
        console.log("Initial Balance of pool:", address(sideEntranceLenderPool).balance / 1e18);
        console.log("Initial Balance of player:", address(player).balance / 1e18);

        Attacker attacker = new Attacker(address(sideEntranceLenderPool));
        attacker.attack(address(sideEntranceLenderPool).balance);
        attacker.execute();
        attacker.withdraw();
        vm.stopPrank();
        validation();

        console.log(unicode"\n🎉 Congratulations, you can go to the next level! 🎉");
        console.log("Initial Balance of pool:", address(sideEntranceLenderPool).balance / 1e18);
        console.log("Initial Balance of player:", address(player).balance / 1e18);
    }

    function validation() view internal {
        assertEq(address(sideEntranceLenderPool).balance, 0);
        assertGt(address(player).balance, ETHER_IN_POOL);
    }
}
