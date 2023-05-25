// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./EigenLayerParser.sol";

// forge script script/GrantPermission.s.sol:GrantPermission --rpc-url http://127.0.0.1:9545  --private-key 74e58c0127a59c8745568e7b4b6f41a4ad27875d2678358e0a0431f8385e5e9d --broadcast -vvvv
contract GrantPermission is Script, DSTest, EigenLayerParser {
    function run() external {
        parseEigenLayerParams();
        vm.startBroadcast();
        address operatorAddr;
        for (uint256 i = 0; i < numDln; i++) {
            operatorAddr = stdJson.readAddress(configJson, string.concat(".dln[", string.concat(vm.toString(i), "].address")));
            rgPermission.addOperatorPermission(operatorAddr);
        }
        vm.stopBroadcast();
    }
}
