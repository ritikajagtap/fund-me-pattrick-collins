// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from 'forge-std/Script.sol';
import {FundMe} from '../src/FundMe.sol';
import {HelperConfig} from "./HelperConfig.s.sol";
contract DeployFundMe is Script{
    function run()  external returns (FundMe){
        // Before boradcast -> no real transaction
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        // after boradcast ->  real transaction
        vm.startBroadcast();
        // Mock
        
        FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        vm.stopBroadcast();
        return fundMe;
    }    
}