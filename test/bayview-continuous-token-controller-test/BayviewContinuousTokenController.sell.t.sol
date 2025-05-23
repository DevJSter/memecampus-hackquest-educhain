// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { IBayviewContinuousToken } from "../../contracts/interfaces/IBayviewContinuousToken.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { BayviewContinuousTokenControllerTest } from "./BayviewContinuousTokenController.t.sol";

contract BayviewContinuousTokenControllerSellTest is BayviewContinuousTokenControllerTest {
    modifier setup() {
        vm.deal(owner, 5 ether);
        vm.deal(bob, 5 ether);

        vm.prank(owner);
        token = IBayviewContinuousToken(
            controller.deployBayviewContinuousToken{ value: 2 ether } (
                "Big Booty Latina",
                "$BLB"
            )
        );

        vm.prank(bob);
        controller.buy{ value: 2 ether }(token);
        _;
    }

    function testSell() public setup {
        uint256 balanceOfBob = IERC20(address(token)).balanceOf(bob);
        vm.prank(bob);
        controller.sell(token, balanceOfBob);
    }
}