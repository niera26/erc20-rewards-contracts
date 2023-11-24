// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import {ERC20RewardsTest} from "./ERC20RewardsTest.t.sol";

contract DistributeTest is ERC20RewardsTest {
    function testDistributeSwap() public {
        address user1 = vm.addr(1);
        address user2 = vm.addr(2);
        address user3 = vm.addr(3);
        address user4 = vm.addr(3);

        // set the buy fee to something easy to compute.
        token.setBuyFee(800, 200);

        // add some tax.
        buyToken(user4, 1 ether);

        // send the same value to two users.
        uint256 balance = token.balanceOf(user4);
        uint256 quarter = balance / 4;

        vm.prank(user4);

        token.transfer(user1, quarter * 2);

        vm.prank(user4);

        token.transfer(user2, quarter);

        vm.prank(user4);

        token.transfer(user3, quarter);

        // two users should get the same rewards.
        token.distribute();

        assertGt(token.pendingRewards(user1), 0);
        assertGt(token.pendingRewards(user2), 0);
        assertGt(token.pendingRewards(user3), 0);
        assertEq(token.pendingRewards(user2), token.pendingRewards(user3));
        assertApproxEqAbs(token.pendingRewards(user1), token.pendingRewards(user2) + token.pendingRewards(user3), 1);
        assertGt(rewardToken.balanceOf(token.marketingWallet()), 0);

        // two users should claim the same amount.
        vm.prank(user1);

        token.claim();

        vm.prank(user2);

        token.claim();

        vm.prank(user3);

        token.claim();

        assertGt(rewardToken.balanceOf(user1), 0);
        assertGt(rewardToken.balanceOf(user2), 0);
        assertGt(rewardToken.balanceOf(user3), 0);
        assertEq(rewardToken.balanceOf(user2), rewardToken.balanceOf(user3));
        assertApproxEqAbs(rewardToken.balanceOf(user1), rewardToken.balanceOf(user2) + rewardToken.balanceOf(user3), 1);

        // check marketing amount.
        uint256 distributed = rewardToken.balanceOf(user1) + rewardToken.balanceOf(user2) + rewardToken.balanceOf(user2)
            + rewardToken.balanceOf(token.marketingWallet());

        assertApproxEqRel(rewardToken.balanceOf(token.marketingWallet()), distributed / 5, 0.01e18);
    }

    function testDistributeMoreToken() public {
        address user1 = vm.addr(1);
        address user2 = vm.addr(2);
        address user3 = vm.addr(3);

        // get some rewards token.
        buyToken(user1, 1 ether);
        buyToken(user2, 1 ether);
        buyToken(user3, 1 ether);

        // anyone can send tokens to the contract.
        uint256 balance1 = token.balanceOf(user1);

        vm.prank(user1);

        token.transfer(address(token), balance1 / 2);

        uint256 balance2 = token.balanceOf(user2);

        vm.prank(user2);

        token.transfer(address(token), balance2 / 2);

        uint256 balance3 = token.balanceOf(user3);

        vm.prank(user3);

        token.transfer(address(token), balance3 / 2);

        // rewards should be distributed.
        token.distribute();

        vm.prank(user1);

        token.claim();

        vm.prank(user2);

        token.claim();

        vm.prank(user3);

        token.claim();

        assertGt(rewardToken.balanceOf(user1), 0);
        assertGt(rewardToken.balanceOf(user2), 0);
        assertGt(rewardToken.balanceOf(user3), 0);
        //assertEq(token.balanceOf(address(token)), 0);
        //assertEq(rewardToken.balanceOf(address(token)), 0);
    }

    function testDistributeMoreRewardToken() public {
        address user1 = vm.addr(1);
        address user2 = vm.addr(2);
        address user3 = vm.addr(3);

        // get some rewards token.
        buyToken(user1, 1 ether);
        buyToken(user2, 1 ether);
        buyToken(user3, 1 ether);

        token.distribute();

        vm.prank(user1);

        token.claim();

        vm.prank(user2);

        token.claim();

        vm.prank(user3);

        token.claim();

        // anyone can send reward tokens to the contract.
        uint256 rewardTokenBalance1 = rewardToken.balanceOf(user1);

        vm.prank(user1);

        rewardToken.transfer(address(token), rewardTokenBalance1);

        uint256 rewardTokenBalance2 = rewardToken.balanceOf(user2);

        vm.prank(user2);

        rewardToken.transfer(address(token), rewardTokenBalance2);

        uint256 rewardTokenBalance3 = rewardToken.balanceOf(user3);

        vm.prank(user3);

        rewardToken.transfer(address(token), rewardTokenBalance3);

        // rewards should be distributed.
        token.distribute();

        vm.prank(user1);

        token.claim();

        vm.prank(user2);

        token.claim();

        vm.prank(user3);

        token.claim();

        assertGt(rewardToken.balanceOf(user1), 0);
        assertGt(rewardToken.balanceOf(user2), 0);
        assertGt(rewardToken.balanceOf(user3), 0);

        // collect more taxes.
        buyToken(user1, 1 ether);
        buyToken(user2, 1 ether);
        buyToken(user3, 1 ether);

        // send on top of taxes.
        rewardTokenBalance1 = rewardToken.balanceOf(user1);

        vm.prank(user1);

        rewardToken.transfer(address(token), rewardTokenBalance1);

        rewardTokenBalance2 = rewardToken.balanceOf(user2);

        vm.prank(user2);

        rewardToken.transfer(address(token), rewardTokenBalance2);

        rewardTokenBalance3 = rewardToken.balanceOf(user3);

        vm.prank(user3);

        rewardToken.transfer(address(token), rewardTokenBalance3);

        // taxes and sent rewards should be distributed.
        token.distribute();

        vm.prank(user1);

        token.claim();

        vm.prank(user2);

        token.claim();

        vm.prank(user3);

        token.claim();

        assertGt(rewardToken.balanceOf(user1), 0);
        assertGt(rewardToken.balanceOf(user2), 0);
        assertGt(rewardToken.balanceOf(user3), 0);
    }
}
