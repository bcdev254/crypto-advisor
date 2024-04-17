# Crypto Advisor Marketplace on SUI

## Overview:
This project implements a decentralized marketplace for booking sessions with crypto advisors on the SUI blockchain. Users can create sessions, book sessions with advisors, submit payments, and resolve disputes through smart contracts. It leverages the SUI blockchain's capabilities for secure and transparent transactions.

## Features:
- **Session Booking:** Users can create sessions with descriptions and set prices. Advisors can accept session requests.
- **Payment Escrow:** Payments are held in escrow until sessions are completed, ensuring security for both parties.
- **Dispute Resolution:** In case of disputes, users can trigger a resolution process to decide whether to release funds or refund the client.
- **Refunds:** Clients can request refunds if sessions are not scheduled or completed as agreed upon.

## How to Deploy:
To deploy this project on SUI, follow these steps:

1. **Build Contracts:** Build the smart contracts using the `sui move build` command.

2. **Deploy Contracts:** Deploy the compiled contracts to the SUI blockchain using your preferred deployment method 'sui client publish --gas-budget 100000000'(e.g., SUI CLI, SUI IDE).

3. **Interact with Contracts:** Use SUI transactions to interact with the deployed contracts, such as creating sessions, booking sessions, submitting payments, resolving disputes, and requesting refunds.

4. **Testing:** Thoroughly test the functionality of the deployed contracts to ensure they behave as expected under different scenarios.

## Code Explanation:

- **Module:** The main module `crypto_advisor_marketplace::crypto_advisor_marketplace` encapsulates the entire functionality of the crypto advisor marketplace.

- **Structs:** The `AdvisorSession` struct represents a session created by a user, storing information such as the session ID, client, advisor, description, price, escrow balance, session status, and dispute status.

- **Entry Functions:** These are public functions accessible via transactions that allow users to interact with the marketplace, including booking sessions, submitting payments, resolving disputes, and requesting refunds.

    - **Session Booking:** `book_session`: Allows users to create sessions with descriptions and set prices. Advisors can accept session requests through `request_session`.
    
    - **Payment Handling:** `add_funds_to_session`: Users can add funds to a session's escrow balance. Payment release is managed through `release_payment`.
    
    - **Dispute Resolution:** `dispute_session` triggers a dispute, and `resolve_dispute` resolves disputes by deciding whether to release funds or refund the client.
    
    - **Refunds:** Users can request refunds if sessions are not scheduled or completed as agreed upon using `request_refund`.

- **Error Constants:** Error constants are defined to handle various error scenarios during contract execution, ensuring robustness and reliability.

- **Additional Functions:** These functions provide additional functionality, such as updating session descriptions and prices (`update_session_description`, `update_session_price`).

## Build Process:
To build the smart contract, use the command `sui move build`. This command compiles the Move source code into bytecode and generates artifacts necessary for deployment.

## Deployment:
After building the smart contract, deploy it to the SUI blockchain using the `sui client publish --gas-budget 100000000` command with appropriate gas budget allocation.

## Testing:
Thoroughly test the functionality of the deployed contracts to ensure they behave as expected under different scenarios. You can simulate various user interactions and edge cases to validate the contract's behavior.

## Contributing:
Contributions to this project are welcome! If you have suggestions for improvements or new features, feel free to submit pull requests or open issues on the project repository.

## License:
This project is licensed under the MIT License, providing freedom for users to use, modify, and distribute the code.

## Contact:
For questions or inquiries, contact the author or maintainer of the project.

## Enjoy using the Crypto Advisor Marketplace on SUI!

