# Collateralized Loan Contract

## Project Description

The **Collateralized Loan Contract** allows users to borrow against collateral with repayment terms. Users can deposit collateral in the form of ERC-20 tokens and borrow a certain amount of tokens, with the contract ensuring that loans are collateralized at a minimum threshold. The contract calculates interest over time, and users must repay both the principal and accrued interest. In case of default, where the collateral value falls below the required threshold, the collateral is liquidated to cover the loan.

## Contract Address

The **Collateralized Loan Contract** is deployed at the following address:

**Contract Address**: [0xd9145CCE52D386f254917e481eB44e9943F39138](https://etherscan.io/address/0xd9145CCE52D386f254917e481eB44e9943F39138)

## Features

- **Collateralized Loans**: Users deposit collateral in ERC-20 tokens and borrow funds based on a certain loan-to-collateral ratio.
- **Interest Accrual**: Interest is accrued on the loan amount over time, with an annual rate that is applied on a daily basis.
- **Loan Repayment**: Users can repay the loan principal plus the accrued interest at any time.
- **Liquidation**: If the collateral value falls below a defined threshold due to interest accrual or market depreciation, the collateral is seized to cover the loan.
- **Flexible Terms**: The contract allows users to set their loan terms (interest rate, collateral amount, etc.) as per the requirements.

## How It Works

### 1. **Deposit Collateral & Take Loan**
   - Users deposit collateral (in ERC-20 tokens) and request a loan. The loan is granted based on the collateral-to-loan ratio.
   - Collateral is required to exceed a certain threshold based on the loan value.
   
### 2. **Accrual of Interest**
   - Interest on the loan is calculated annually but accrues on a daily basis. The rate is set when the loan is taken.
   
### 3. **Repayment**
   - Users can repay their loan at any time, including the principal and any accrued interest.

### 4. **Liquidation**
   - If the collateral value falls below the required threshold (due to accrued interest or market changes), the loan is liquidated, and the collateral is seized to cover the debt.

## How to Use

### 1. Deploy the Contract

After compiling the contract, deploy it to the Ethereum network using tools like Remix, Truffle, or Hardhat.

### 2. Set the Token Address

Once deployed, set the token address that will be used for collateral and loan issuance:

```solidity
setToken(address_of_your_token);

