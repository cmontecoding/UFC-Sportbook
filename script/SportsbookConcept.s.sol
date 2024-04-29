// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Script} from "../lib/forge-std/src/Script.sol";
import {Sportsbook} from "../src/SportsbookConcept.sol";

/**
 *
 * TESTNET DEPLOYMENT: Base Testnet (Sepolia)
 *
 */

contract BaseTestnetDeploy is Script {
    /// @dev contracts being deployed
    Sportsbook public sportsbook;

    /// @dev constructor arguments
    address constant AUTHORIZED = 0xc716431c005E03eDC2E5aBc2a726513f500Da6C3;

    function run() public {
        /// @dev get the deployer's private key
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        /// @dev deploy contracts
        sportsbook = new Sportsbook({
            _authorized: AUTHORIZED
        });

        vm.stopBroadcast();
    }
}

/**
 * TO DEPLOY:
 *
 * To load the variables in the .env file
 * > source .env
 *
 * To deploy and verify our contract
 * > forge script script/SportsbookConcept.s.sol:BaseTestnetDeploy --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast --verify -vvvv
 */

