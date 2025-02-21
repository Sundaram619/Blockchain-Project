// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CollateralizedLoan {

    struct Loan {
        uint256 collateralAmount;
        uint256 loanAmount;
        uint256 interestRate;
        uint256 debt;
        uint256 lastUpdateTime;
    }

    address public token; // ERC-20 token address for the loan and collateral
    uint256 public liquidationThreshold; // Percentage for liquidation (e.g., 150% of loan amount)
    
    mapping(address => Loan) public loans;

    // Set the token and liquidation threshold (manually, no constructor)
    function setToken(address _token) external {
        token = _token;
    }

    function setLiquidationThreshold(uint256 _threshold) external {
        liquidationThreshold = _threshold; // For example, 150 means 150% collateral
    }

    // Function to deposit collateral and request a loan
    function depositCollateralAndTakeLoan(uint256 collateralAmount, uint256 loanAmount, uint256 interestRate) external {
        require(collateralAmount > 0, "Collateral must be greater than 0");
        require(loanAmount > 0, "Loan amount must be greater than 0");
        
        // Transfer the collateral token to the contract
        bool success = IERC20(token).transferFrom(msg.sender, address(this), collateralAmount);
        require(success, "Collateral transfer failed");

        // Calculate the required collateralization
        uint256 requiredCollateral = loanAmount * liquidationThreshold / 100;
        require(collateralAmount >= requiredCollateral, "Not enough collateral for the loan");

        // Update the loan structure
        Loan storage loan = loans[msg.sender];
        loan.collateralAmount = collateralAmount;
        loan.loanAmount = loanAmount;
        loan.interestRate = interestRate;
        loan.debt = loanAmount;
        loan.lastUpdateTime = block.timestamp;

        // Transfer loan to the borrower
        success = IERC20(token).transfer(msg.sender, loanAmount);
        require(success, "Loan transfer failed");
    }

    // Function to accrue interest and repay the loan
    function repayLoan(uint256 repayAmount) external {
        Loan storage loan = loans[msg.sender];
        require(loan.loanAmount > 0, "No loan found");
        uint256 timeElapsed = block.timestamp - loan.lastUpdateTime;
        
        // Accrue interest based on the interest rate
        uint256 interestAccrued = (loan.debt * loan.interestRate * timeElapsed) / (365 days * 100);
        loan.debt += interestAccrued;

        // Ensure the repayment is sufficient
        require(repayAmount >= loan.debt, "Repay amount is less than the debt");

        // Transfer repayment to the contract
        bool success = IERC20(token).transferFrom(msg.sender, address(this), repayAmount);
        require(success, "Repayment failed");

        // Reset the loan details once repaid
        loan.collateralAmount = 0;
        loan.loanAmount = 0;
        loan.debt = 0;
    }

    // Function to check if the loan is over-collateralized or liquidated
    function checkLoanStatus() external {
        Loan storage loan = loans[msg.sender];
        require(loan.loanAmount > 0, "No loan found");

        // Accrue interest
        uint256 timeElapsed = block.timestamp - loan.lastUpdateTime;
        uint256 interestAccrued = (loan.debt * loan.interestRate * timeElapsed) / (365 days * 100);
        loan.debt += interestAccrued;

        // Check if collateral is sufficient
        uint256 requiredCollateral = loan.loanAmount * liquidationThreshold / 100;
        if (loan.collateralAmount < requiredCollateral) {
            // Liquidation: Seize collateral and reset loan
            bool success = IERC20(token).transfer(msg.sender, loan.collateralAmount);
            require(success, "Collateral transfer failed");

            // Reset the loan details
            loan.collateralAmount = 0;
            loan.loanAmount = 0;
            loan.debt = 0;
        }
    }

    // Function to check the outstanding loan and debt
    function getLoanDetails() external view returns (uint256 loanAmount, uint256 collateralAmount, uint256 debt, uint256 interestRate) {
        Loan storage loan = loans[msg.sender];
        uint256 timeElapsed = block.timestamp - loan.lastUpdateTime;
        
        // Accrue interest
        uint256 interestAccrued = (loan.debt * loan.interestRate * timeElapsed) / (365 days * 100);
        uint256 totalDebt = loan.debt + interestAccrued;

        return (loan.loanAmount, loan.collateralAmount, totalDebt, loan.interestRate);
    }

    // Function to calculate the interest on the loan
    function calculateInterest(address borrower) public view returns (uint256) {
        Loan storage loan = loans[borrower];
        uint256 timeElapsed = block.timestamp - loan.lastUpdateTime;
        uint256 interestAccrued = (loan.debt * loan.interestRate * timeElapsed) / (365 days * 100);
        return loan.debt + interestAccrued;
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}
