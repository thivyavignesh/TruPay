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

        bool added_broker;
        bool broker_paid;
    }
    
    seller private seller_info;
    address seller_broker;
    
    struct buyer {
        address addr;
        uint256 paid_amt; // escrow + value of the product
        bool paid;
        bool retrieved_escrow;
        
        bool added_broker;
        bool broker_paid;
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
    
    function add_data(uint256 _escrow, uint256 _val_product, string decrypt_key, string hashData) external onlyOwner {
        require (update_data == 1);
        require (buyer_enrolled == false);
        
        seller memory seller_det = seller(_escrow, false, _val_product, decrypt_key, hashData, false, false, false);
        seller_info = seller_det;
    }
    
    function add_seller_broker (address _broker_address) external onlyOwner {
        require (update_data == 0);
        require (seller_info.added_broker == false);
        
        seller_broker = _broker_address;
        seller_info.added_broker = true;
    }
    
    function pay_escrow_by_seller_broker() public payable {
        require (seller_info.added_broker == true);
        require (msg.sender == seller_broker);
        require (seller_info.broker_paid == false);
        require (msg.value == seller_info.escrow);
        
        seller_info.broker_paid = true;
    }
    
    function pay_escrow_by_seller() external onlyOwner payable {
        require (seller_info.paid_escrow == false);
        require (msg.value == seller_info.escrow);
        require (buyer_enrolled == false);
        require (seller_info.added_broker == true);
        
        update_data = 0;
        seller_info.paid_escrow = true;
    }
    
    function enroll_buyer() public {
        require (update_data == 0);
        require (buyer_enrolled == false);
        
        buyer memory buyer_det = buyer(msg.sender, 0, false, false, false, false);
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
    
    function add_buyer_broker (address _broker_address) public {
        require (buyer_enrolled == true);
        require (buyer_info.added_broker == false);
        require (msg.sender == buyer_info.addr);
        
        buyer_broker = _broker_address;
        buyer_info.added_broker = true;
    }
    
    function pay_escrow_by_buyer_broker() public payable {
        require (buyer_info.added_broker == true);
        require (msg.sender == buyer_broker);
        require (buyer_info.broker_paid == false);
        require (msg.value == seller_info.escrow);
        
        buyer_info.broker_paid = true;
    }
    
    function check_integrity (bool _integrity) public returns (string decrypt_key) {
        require (msg.sender == buyer_info.addr);
        require (buyer_info.paid == true);
        require (seller_info.paid_escrow == true);
        require (seller_info.broker_paid == true);
        require (buyer_info.broker_paid == true);
        
        if (_integrity) {
            buyer_broker.transfer(uint256(seller_info.escrow + (seller_info.val_product*5/100)));
            seller_broker.transfer(uint256(seller_info.escrow + (seller_info.val_product*5/100)));
            
            check_integ = true;
            
            return (seller_info.decryption_key);            
        } else {
            msg.sender.transfer(uint256(seller_info.val_product));
            
            return ('');
        }
    }
    
    function validate_product (bool _valid) public returns (bool payment_status) { 
        // passed true if valid else false
        require (check_integ == true);
        require (msg.sender == buyer_info.addr);
        require (buyer_info.retrieved_escrow == false);
        require (seller_info.retrieved_escrow == false);

        
        if (_valid) {
            msg.sender.transfer(uint256(seller_info.escrow));
            owner.transfer(uint256(seller_info.escrow + (seller_info.val_product*9/10)));
            
            seller_info.retrieved_escrow = true;
            buyer_info.retrieved_escrow = true;
            
            return true;
        } else {
            msg.sender.transfer(uint256(seller_info.val_product*9/10));
            
            return false;
        }
        
    }

    function getEscrowValue() public view returns (uint256) {
        require (update_data == 0);
        
        return (seller_info.escrow);
    }
    
    function getHashData() public view returns (string) {
        require (update_data == 0);
        
        return (seller_info.hash_data);
    }
    
    function checkTransactionValid() public view returns (bool) {
        return (seller_info.retrieved_escrow && buyer_info.retrieved_escrow);
    }
  
    function terminate() external onlyOwner {
        require (address(this).balance == 0);
        selfdestruct(owner);
    }
}