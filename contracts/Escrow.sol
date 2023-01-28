// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract escrowContract {
    error Unauthorized();
    error InvalidInput();
    error InsufficientFunds();

    event amountEscrowed(address Sender, address _receiver, uint amtEscrowed);
    event txComplete(uint _txId);
    uint private txCounter;
    address private admin;
    IERC20 private currency;
    /*
            #Developed by Ibraziz21
            This contract has 2 users, a buyer, and a seller (Marketplace style)
            Buyer sends a currency to the escrow contract. Once The Buyer Receives the item/service they require from the sender,
            The buyer then releases the amount from the escrow to the seller 

    */
   struct Escrow {
        uint amount;
        IERC20 currencyStored;
        address sender;
        address receiver;
        bool ItemDelivered;
        bool received;
   }
   mapping (uint => Escrow) public escrowDetails;
    constructor(address initialCurrency) {
        admin = msg.sender;
        currency = IERC20(initialCurrency);
    }
    modifier onlyAdmin {
        if(msg.sender!=admin) revert Unauthorized();
        _;
    }
    modifier validAddress(address _address) {
         if(_address==address(0)) revert InvalidInput();
         _;
    }
    function changeAdmin(address newAdmin) external onlyAdmin validAddress(newAdmin){ 
        admin = newAdmin;
    }
    function changeCurrency(address newCurrency) external onlyAdmin validAddress(newCurrency){
        currency = IERC20(newCurrency);
    }

    function sendToEscrow(uint _amount, address _receiver) external validAddress(_receiver){
        if (_amount==0)revert InvalidInput();
        if(currency.balanceOf(msg.sender)<_amount) revert InsufficientFunds();
       (bool success) = currency.transferFrom(msg.sender,address(this), _amount);
       if(success){
            txCounter++;
            Escrow storage escrow = escrowDetails[txCounter];
            escrow.sender = msg.sender;
            escrow.receiver = _receiver;
            escrow.amount = _amount;
            escrow.currencyStored = currency;

            emit amountEscrowed(msg.sender, _receiver, _amount);

       }
      function receivedItems(uint txID) external{
            Escrow storage escrow = escrowDetails[txID];
            if(escrow.sender!=msg.sender) revert NotAuthorized();
            escrow.ItemDelivered = true;
            escrow.received = true;
            uint amount = escrow.amount;
            address receiver = escrow.receiver;
            currency.transfer(receiver, amount);

            emit txComplete(txID);
       }

    }




}
