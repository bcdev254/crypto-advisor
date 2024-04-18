module crypto_advisor_marketplace::crypto_advisor_marketplace {

    // Imports
    use sui::transfer;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use std::option::{Option, none, some, is_some, contains, borrow};

    // Errors
    const EInvalidBooking: u64 = 1;
    const EInvalidSession: u64 = 2;
    const EDispute: u64 = 3;
    const EAlreadyResolved: u64 = 4;
    const ENotBooked: u64 = 5;
    const EInvalidWithdrawal: u64 = 7;

    // Struct definitions
    struct AdvisorSession has key, store {
        id: UID,
        client: address,
        advisor: Option<address>,
        description: vector<u8>,
        price: u64,
        escrow: Balance<SUI>,
        sessionScheduled: bool,
        dispute: bool,
    }

    // Module initializer

    // Accessors
    public entry fun get_session_description(session: &AdvisorSession): vector<u8> {
        session.description
    }

    public entry fun get_session_price(session: &AdvisorSession): u64 {
        session.price
    }

    // Public - Entry functions
    public entry fun book_session(description: vector<u8>, price: u64, ctx: &mut TxContext) {

        let session_id = object::new(ctx);
        transfer::share_object(AdvisorSession {
            id: session_id,
            client: tx_context::sender(ctx),
            advisor: none(), // Set to an initial value, can be updated later
            description: description,
            price: price,
            escrow: balance::zero(),
            sessionScheduled: false,
            dispute: false,
        });
    }

    public entry fun request_session(advisor_session: &mut AdvisorSession, ctx: &mut TxContext) {
        assert!(!is_some(&advisor_session.advisor), EInvalidBooking);
        advisor_session.advisor = some(tx_context::sender(ctx));
    }

    public entry fun submit_session(advisor_session: &mut AdvisorSession, ctx: &mut TxContext) {
        assert!(contains(&advisor_session.advisor, &tx_context::sender(ctx)), EInvalidSession);
        advisor_session.sessionScheduled = true;
    }

    public entry fun dispute_session(advisor_session: &mut AdvisorSession, ctx: &mut TxContext) {
        assert!(advisor_session.client == tx_context::sender(ctx), EDispute);
        advisor_session.dispute = true;
    }

    public entry fun resolve_dispute(advisor_session: &mut AdvisorSession, resolved: bool, ctx: &mut TxContext) {
        assert!(advisor_session.client == tx_context::sender(ctx), EDispute);
        assert!(advisor_session.dispute, EAlreadyResolved);
        assert!(is_some(&advisor_session.advisor), EInvalidBooking);
        let escrow_amount = balance::value(&advisor_session.escrow);
        let escrow_coin = coin::take(&mut advisor_session.escrow, escrow_amount, ctx);
        if (resolved) {
            let advisor = *borrow(&advisor_session.advisor).unwrap();
            // Transfer funds to the advisor
            transfer::public_transfer(escrow_coin, advisor);
        } else {
            // Refund funds to the client
            transfer::public_transfer(escrow_coin, advisor_session.client);
        };

        // Reset session state
        advisor_session.advisor = none();
        advisor_session.sessionScheduled = false;
        advisor_session.dispute = false;
    }

    public entry fun release_payment(advisor_session: &mut AdvisorSession, ctx: &mut TxContext) {
        assert!(advisor_session.client == tx_context::sender(ctx), ENotBooked);
        assert!(advisor_session.sessionScheduled && !advisor_session.dispute, EInvalidSession);
        assert!(is_some(&advisor_session.advisor), EInvalidBooking);
        let advisor = *borrow(&advisor_session.advisor).unwrap();
        let escrow_amount = balance::value(&advisor_session.escrow);
        let escrow_coin = coin::take(&mut advisor_session.escrow, escrow_amount, ctx);
        // Transfer funds to the advisor
        transfer::public_transfer(escrow_coin, advisor);

        // Reset session state
        advisor_session.advisor = none();
        advisor_session.sessionScheduled = false;
        advisor_session.dispute = false;
    }

    // Additional functions
    public entry fun cancel_session(advisor_session: &mut AdvisorSession, ctx: &mut TxContext) {
        assert!(advisor_session.client == tx_context::sender(ctx) || contains(&advisor_session.advisor, &tx_context::sender(ctx)), ENotBooked);

        // Refund funds to the client if not yet paid
        if (is_some(&advisor_session.advisor) && !advisor_session.sessionScheduled && !advisor_session.dispute) {
            let escrow_amount = balance::value(&advisor_session.escrow);
            let escrow_coin = coin::take(&mut advisor_session.escrow, escrow_amount, ctx);
            transfer::public_transfer(escrow_coin, advisor_session.client);
        };

        // Reset session state
        advisor_session.advisor = none();
        advisor_session.sessionScheduled = false;
        advisor_session.dispute = false;
    }

    public entry fun update_session_description(advisor_session: &mut AdvisorSession, new_description: vector<u8>, ctx: &mut TxContext) {
        assert!(advisor_session.client == tx_context::sender(ctx), ENotBooked);
        advisor_session.description = new_description;
    }

    public entry fun update_session_price(advisor_session: &mut AdvisorSession, new_price: u64, ctx: &mut TxContext) {
        assert!(advisor_session.client == tx_context::sender(ctx), ENotBooked);
        advisor_session.price = new_price;
    }

    // New functions
    public entry fun add_funds_to_session(advisor_session: &mut AdvisorSession, amount: Coin<SUI>, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == advisor_session.client, ENotBooked);
        let added_balance = coin::into_balance(amount);
        balance::join(&mut advisor_session.escrow, added_balance);
    }

    public entry fun request_refund(advisor_session: &mut AdvisorSession, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == advisor_session.client, ENotBooked);
        assert!(!advisor_session.sessionScheduled, EInvalidWithdrawal); // Check if session is not scheduled
        let escrow_amount = balance::value(&advisor_session.escrow);
        let escrow_coin = coin::take(&mut advisor_session.escrow, escrow_amount, ctx);
        // Refund funds to the client
        transfer::public_transfer(escrow_coin, advisor_session.client);

        // Reset session state
        advisor_session.advisor = none();
        advisor_session.sessionScheduled = false;
        advisor_session.dispute = false;
    }

    // public entry fun update_session_deadline(advisor_session: &mut AdvisorSession, new_deadline: u64, ctx: &mut TxContext) {
    //     assert!(tx_context::sender(ctx) == advisor_session.client, ENotBooked);
    //     // Additional logic to update the session's deadline
    // }

    public entry fun mark_session_complete(advisor_session: &mut AdvisorSession, ctx: &mut TxContext) {
        assert!(contains(&advisor_session.advisor, &tx_context::sender(ctx)), ENotBooked);
        advisor_session.sessionScheduled = true;
        // Additional logic to mark the session as complete
    }

    // public entry fun extend_dispute_period(advisor_session: &mut AdvisorSession, extension_days: u64, ctx: &mut TxContext) {
    //     assert!(tx_context::sender(ctx) == advisor_session.client, ENotBooked);
    //     assert!(advisor_session.dispute, EInvalidUpdate);
    //     // Additional logic to extend the dispute period
    // }

    public entry fun extend_dispute_period(advisor_session: &mut AdvisorSession, extension_days: u64, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == advisor_session.client, ENotBooked);
        assert!(advisor_session.dispute, EInvalidUpdate);
        
        // Calculate the new dispute deadline
        let current_time = tx_context::block_time(ctx);
        let current_deadline = current_time + extension_days * 24 * 60 * 60; // Convert days to seconds
        advisor_session.dispute_deadline = current_deadline;
    }

    public entry fun update_session_deadline(advisor_session: &mut AdvisorSession, new_deadline: u64, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == advisor_session.client, ENotBooked);
        assert!(advisor_session.sessionScheduled, EInvalidUpdate);

        // Update the session deadline
        advisor_session.deadline = new_deadline;
    }

}
