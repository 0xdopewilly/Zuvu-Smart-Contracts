// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ZuvuFundsDistributor {
    // Event to log fund distribution
    event FundsDistributed(
        address indexed sender,
        uint256 totalAmount,
        address[] recipients,
        uint256[] amounts
    );

    // Predefined list of recipients
    address[] public recipients;

    /**
     * @dev Constructor to set the recipients at deployment.
     * @param _recipients Array of recipient addresses.
     */
    constructor(address[] memory _recipients) {
        require(_recipients.length > 0, "Recipients list cannot be empty");
        recipients = _recipients;
    }

    /**
     * @dev Function to distribute funds based on splits.
     * @param totalAmount Total amount of tokens to distribute.
     * @param splits Array of percentage splits (must sum to 100).
     */
    function forward_funds(uint256 totalAmount, uint256[] memory splits) external payable {
        require(splits.length == recipients.length, "Splits and recipients length mismatch");
        require(totalAmount == msg.value, "Insufficient funds sent");

        uint256 totalSplit = 0;

        // Validate splits sum to 100
        for (uint256 i = 0; i < splits.length; i++) {
            totalSplit += splits[i];
        }
        require(totalSplit == 100, "Splits must sum to 100");

        uint256[] memory distributedAmounts = new uint256[](splits.length);

        // Distribute funds
        for (uint256 i = 0; i < splits.length; i++) {
            uint256 amount = (totalAmount * splits[i]) / 100;
            distributedAmounts[i] = amount;

            // Transfer Ether
            payable(recipients[i]).transfer(amount);
        }

        // Emit event
        emit FundsDistributed(msg.sender, totalAmount, recipients, distributedAmounts);
    }

    // Fallback function to receive Ether
    receive() external payable {}
}