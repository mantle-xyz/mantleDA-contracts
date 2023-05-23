// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./EigenLayerParser.sol";

contract DepositAndDelegate is Script, DSTest, EigenLayerParser {

    //performs basic deployment before each test
    function run() external {
        parseEigenLayerParams();

        // uint256 wethAmount = eigenTotalSupply / (numStaker + numDis + 50); // save 100 portions
        uint256 wethAmount;

        address dlnAddr;

        //get the corresponding dln
        //is there an easier way to do this?
        for (uint256 i = 0; i < numStaker; i++) {
            address stakerAddr =
                stdJson.readAddress(configJson, string.concat(".staker[", string.concat(vm.toString(i), "].address")));

            wethAmount = vm.parseUint(stdJson.readString(configJson, string.concat(".staker[", string.concat(vm.toString(i), "].stake"))));

            if (stakerAddr == msg.sender) {
                dlnAddr =
                    stdJson.readAddress(configJson, string.concat(".dln[", string.concat(vm.toString(i), "].address")));
                    break;
            }
        }

        emit log("wethAmount");
        emit log_uint(wethAmount);

        vm.startBroadcast(msg.sender);
        eigen.approve(address(investmentManager), wethAmount);
        investmentManager.depositIntoStrategy(eigenStrat, eigen, wethAmount);
        weth.approve(address(investmentManager), wethAmount);
        investmentManager.depositIntoStrategy(wethStrat, weth, wethAmount);
        delegation.delegateTo(dlnAddr);
        vm.stopBroadcast();
    }
}