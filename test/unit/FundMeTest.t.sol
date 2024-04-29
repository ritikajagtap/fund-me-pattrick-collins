// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract FundMeTest is StdCheats, Test{
    uint256 num = 1;
    FundMe fundMe;

    address public constant USER = address(1);
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;
    function setUp() external{
        // fundMe = new FundMe(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }
    function testMinimumDollarIsFive() public{
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
    function testOwnerIsMsgSender() public{
        // console.log(fundMe.i_owner());
        // console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }
    // function testPriceFeedVersionIsAccurate() public{
    //     uint256 version = fundMe.getVersion();
    //     console.log("version = ", version);
    //     assertEq(version, 4);
    // }
    function testFundFailsWithoutEnoughETH() public{
        vm.expectRevert();
        // uint256 cat = 1;
        fundMe.fund();
    }
    function testFundUpdatesFundedDataStructure() public{
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
    function testAddsFunderToArrayOfFunders() public{
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }
    function testWithdrawWithASingleFunder() public funded{
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance); 
    }
    function testWithdrawFromMulipleFundersCheaper() public funded{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for(uint160 i = startingFunderIndex; i<numberOfFunders+ startingFunderIndex; i++){
            // vm . prank

            // vm.default= 
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            // fund the fundMe
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
    function testWithdrawFromMulipleFunders() public funded{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for(uint160 i = startingFunderIndex; i<numberOfFunders+ startingFunderIndex; i++){
            // vm . prank

            // vm.default= 
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            // fund the fundMe
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
    
}