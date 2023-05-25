// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./utils/Allocator.sol";
import "./EigenLayerParser.sol";

// forge script script/Allocate.s.sol:Allocate --rpc-url http://127.0.0.1:9545  --private-key 6a6494edf0c00b3d0117f1635ad32a6005587cb6e9e808874da622f7b8925697 --broadcast -vvvv
contract Allocate is Script, DSTest, EigenLayerParser {
    //performs basic deployment before each test
    function run() external {
        // read meta data from json
        parseEigenLayerParams();

        // uint256 wethAmount = eigenTotalSupply / (numStaker + numDis + 50); // save 100 portions
        vm.startBroadcast();

        Allocator allocator = new Allocator();

        weth.approve(address(allocator), type(uint256).max);
        eigen.approve(address(allocator), type(uint256).max);

        address[] memory stakers = new address[](numStaker);
        uint256[] memory amounts = new uint256[](numStaker);
        uint256 totalAmount;
        // deployer allocate weth, eigen to staker
        for (uint i = 0; i < numStaker ; ++i) {
            address stakerAddr = stdJson.readAddress(configJson, string.concat(".staker[", string.concat(vm.toString(i), "].address")));
            stakers[i] = stakerAddr;
            amounts[i] = vm.parseUint(stdJson.readString(configJson, string.concat(".staker[", string.concat(vm.toString(i), "].stake"))));
            totalAmount += amounts[i];
            emit log("stakerAddr");
            emit log_address(stakerAddr);
        }
        allocator.allocateArray(weth, stakers, amounts, totalAmount);
        allocator.allocateArray(eigen, stakers, amounts, totalAmount);

        address[] memory dispersers = new address[](numDis);
        // deployer allocate weth, eigen to disperser
        for (uint i = 0; i < numDis ; ++i) {
            emit log(string.concat(vm.toString(i)));
            address disAddr = stdJson.readAddress(configJson, string.concat(".dis[", string.concat(vm.toString(i), "].address")));
            dispersers[i] = disAddr;
            emit log("disAddr");
            emit log_address(disAddr);
        }

        uint256 wethAmount = eigenTotalSupply / 10 / numDis;
        allocator.allocate(weth, dispersers, wethAmount);

        vm.stopBroadcast();
    }
}

contract ProvisionWeth is Script, DSTest, EigenLayerParser {
    uint256 wethAmount = 100000000000000000000;
    //performs basic deployment before each test

    function run() external {
        vm.startBroadcast();
        // read meta data from json
        addressJson = vm.readFile("data/addresses.json");
        weth = IERC20(stdJson.readAddress(addressJson, ".weth"));
        address dlsm = stdJson.readAddress(addressJson, ".dlsm");
        // deployer allocate weth, eigen to disperser
        uint256 recipientPrivKey = cheats.parseUint(cheats.readLine("data/recipient"));
        emit log_uint(recipientPrivKey);
        address recipientAddr = cheats.addr(recipientPrivKey);
        weth.transfer(recipientAddr, wethAmount);
        payable(recipientAddr).transfer(1 ether);
        vm.stopBroadcast();
        //approve dlsm
        vm.broadcast(recipientPrivKey);
        weth.approve(dlsm, type(uint256).max);
    }
}
