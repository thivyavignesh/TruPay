pragma solidity ^0.4.22;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract TruPay {
    
    using SafeMath for uint256;

    address public owner;
    
    struct seller {
        uint256 escrow; // escrow can be fixed by the business logic / hardcoded in smart contract
        bool paid_escrow; // flag indicating whether the escrow paid at time of contract deployment

        uint256 val_product;
        string decryption_key; // decryption key
        string hash_data; // hash of the encrypted data

        bool retrieved_escrow; // only when the buyer agrees to the receiving data with integrity

        bool added_seller_broker;
        bool seller_broker_paid;
        
        bool added_buyer_broker;
        bool buyer_broker_paid;
    }
    
    seller private seller_info;
    address seller_broker;
    
    struct buyer {
        address addr;
        uint256 paid_amt; // escrow + value of the product
        bool paid;
        bool retrieved_escrow;
    }
    
    buyer private buyer_info;
    address buyer_broker;

    uint256 update_data;
    bool buyer_enrolled;
    bool check_integ;
    
    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }
    
    constructor () public {
        owner = msg.sender;
        update_data = 1;
        buyer_enrolled = false;
        check_integ = false;
    }
    
    function update_state(uint256 _escrow, uint256 _val_product, string decrypt_key, string hashData) external onlyOwner {
        require (update_data == 1);
        
        seller memory seller_det = seller(_escrow, false, _val_product, decrypt_key, hashData, false, false, false, false, false);
        seller_info = seller_det;
    }
    
    function pay_escrow_by_seller() external onlyOwner payable {
        require (seller_info.escrow > 0);
        bytes memory decryption_key = bytes(seller_info.decryption_key);
        require (decryption_key.length > 0);
        bytes memory hash_data = bytes(seller_info.hash_data);
        require (hash_data.length > 0);
        require (seller_info.paid_escrow == false);
        require (msg.value == seller_info.escrow);
        
        update_data = 0;
        seller_info.paid_escrow = true;
    }
    
    function add_seller_broker (address _broker_address) external onlyOwner {
        require (update_data == 0);
        require (seller_info.paid_escrow == true);
        require (seller_info.added_seller_broker == false);
        
        seller_broker = _broker_address;
        seller_info.added_seller_broker = true;
    }
    
    function pay_escrow_by_seller_broker() public payable {
        require (seller_info.added_seller_broker == true);
        require (msg.sender == seller_broker);
        require (seller_info.seller_broker_paid == false);
        require (msg.value == seller_info.escrow);
        
        seller_info.seller_broker_paid = true;
    }
    
    function add_buyer_broker (address _broker_address) public {
        require (msg.sender == seller_broker);
        require (seller_info.seller_broker_paid == true);
        require (seller_info.added_buyer_broker == false);
        
        buyer_broker = _broker_address;
        seller_info.added_buyer_broker = true;
    }
    
    function pay_escrow_by_buyer_broker() public payable {
        require (seller_info.added_buyer_broker == true);
        require (msg.sender == buyer_broker);
        require (seller_info.buyer_broker_paid == false);
        require (msg.value == seller_info.escrow);
        
        seller_info.buyer_broker_paid = true;
    }
    
    function add_buyer(address _broker_address) public {
        require (msg.sender == buyer_broker);
        require (seller_info.buyer_broker_paid == true);
        require (buyer_enrolled == false);
        
        buyer memory buyer_det = buyer(_broker_address, 0, false, false);
        buyer_info = buyer_det;
        buyer_enrolled = true;
    }

    function pay_by_buyer() public payable {
        require (buyer_enrolled == true);
        require (msg.sender == buyer_info.addr);
        require (buyer_info.paid == false);
        require (msg.value == seller_info.escrow + seller_info.val_product);
        
        buyer_info.paid = true;
        buyer_info.paid_amt = msg.value;
    }
    
    function check_integrity (bool _integrity) public returns (string decrypt_key) {
        require (msg.sender == buyer_info.addr);
        require (buyer_info.paid == true);
        require (seller_info.paid_escrow == true);
        require (seller_info.buyer_broker_paid == true);
        require (seller_info.seller_broker_paid == true);
        require (check_integ == false);
        
        if (_integrity) {
            buyer_broker.transfer(uint256(seller_info.escrow + (seller_info.val_product*5/100)));
            seller_broker.transfer(uint256(seller_info.escrow + (seller_info.val_product*5/100)));
            
            check_integ = true;
            
            return (seller_info.decryption_key);            
        } else {
            msg.sender.transfer(uint256(seller_info.val_product*9/10));
            
            return ('');
        }
    }
    
    function validate_static_data (bool _valid) public returns (bool payment_status) { 
        // passed true if valid else false
        require (check_integ == true);
        require (msg.sender == buyer_info.addr);

        
        if (_valid) {
            msg.sender.transfer(uint256(seller_info.escrow));
            owner.transfer(uint256(seller_info.escrow + (seller_info.val_product*9/10)));
            
            seller_info.retrieved_escrow = true;
            buyer_info.retrieved_escrow = true;
            
            return true;
        } else {
            msg.sender.transfer(uint256(seller_info.val_product*5/10));
            
            return false;
        }
        
    }

    function getEscrowValue() public view returns (uint256) {
        require (update_data == 0);
        
        return (seller_info.escrow);
    }
    
    function getHashEncData() public view returns (string) {
        require (update_data == 0);
        
        return (seller_info.hash_data);
    }
    
    function checkTransactionSuccess() public view returns (bool) {
        return (seller_info.retrieved_escrow && buyer_info.retrieved_escrow);
    }
  
    function terminate() external onlyOwner {
        require (address(this).balance == 0);
        selfdestruct(owner);
    }
}
