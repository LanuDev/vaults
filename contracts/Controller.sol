//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/IStrategy.sol";
import "./interfaces/IERC20.sol";
import "./libraries/SafeERC20.sol";
import "./libraries/Address.sol";
import "./libraries/EnumerableSet.sol";

contract Controller {
    using SafeERC20 for IERC20;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    address public strategist;

    // mapping between (token, vault)
    mapping (address => address) vaults;

    // active strategy on certain token (token, strategy)
    mapping (address => address) strategies;

    // token -> strategy[]
    mapping (address => EnumerableSet.AddressSet) availableStrategies;

    constructor() {
        strategist = msg.sender;
    }

    function setVault(address _token, address _vault) public {
        require(msg.sender == strategist, "!strategist");
        require(vaults[_token] == address(0), "vault for this token already deployed");

        vaults[_token] = _vault;
    }

    function setStrategy(address _token, address _strategy) public {
        require(msg.sender == strategist, "!strategist");

        address current = strategies[_token];
        if (current != address(0)) {
            IStrategy(current).withdrawAll();
        }

        strategies[_token] = _strategy;
    }

    function addStrategy(address _token, address _strategy) public {
        require(msg.sender == strategist, "!strategist");
        require(_strategy.isContract(), "Strategy is not a contract");
        require(!availableStrategies[_token].contains(_strategy), "Strategy already exists");

        availableStrategies[_token].add(_strategy);
    }

    function balanceOf(address _token) external view returns (uint256) {
        return IStrategy(strategies[_token]).balanceOf();
    }

    function compareAPY(address _token) internal view returns (address bestStrategy) {

    }
}