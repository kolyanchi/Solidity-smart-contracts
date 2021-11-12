pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "IntShoppingList.sol";

contract ShoppingList is IntShoppingList{
    /*
     * ERROR CODES
     * 100 - Unauthorized
     * 102 - task not found
     */

    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }
    uint8 unreadMessages;
    uint32 m_count = 0;
    uint32 m_count_message = 0;
    bool flag_from_read = false;

    mapping(uint32 => Purchase) m_purchase;
    mapping(uint32 => Message) m_message;

    uint256 m_ownerPubkey;

    constructor( uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    function createPurchase(string name,uint32 count) public onlyOwner override {
        tvm.accept();
        m_count++;
        m_purchase[m_count] = Purchase(m_count, name,count,0, now, false);
    }

    function BuyProduct(uint32 id, uint32 price) public onlyOwner override{
        optional(Purchase) purchase = m_purchase.fetch(id);
        require(purchase.hasValue(), 102);
        tvm.accept();
        Purchase thisPurchase = purchase.get();
        thisPurchase.isDone = true;
        thisPurchase.price = price;
        m_purchase[id] = thisPurchase;
    }

    function deletePurchase(uint32 id) public onlyOwner override{
        require(m_purchase.exists(id), 102);
        tvm.accept();
        delete m_purchase[id];
    }

    //
    // Get methods
    //

    function getPurchases() public override returns (Purchase[] purchases) {
        string name;
        uint32 count;
        uint32 price;
        uint64 timePurchase;
        bool isDone;
        
        //tvm.accept();
        for((uint32 id, Purchase purchase) : m_purchase) {
            name = purchase.name;
            count = purchase.count;
            timePurchase = purchase.timePurchase;
            isDone = purchase.isDone;
            price = purchase.price;

            purchases.push(Purchase(id, name, count,price,timePurchase, isDone));
       }
    }

    function getSammaritPurchases() public override returns (SammaritOfPurchases sammaritOfPurchases) {
        uint32 numberPaidPurchases;
        uint32 numberUnPaidPurchases;
        uint32 totalAmountPurchases;
        tvm.accept();
        for((, Purchase purchase) : m_purchase) {
            if  (purchase.isDone) {
                numberPaidPurchases ++;
            } else {
                numberUnPaidPurchases ++;
            }
            totalAmountPurchases += purchase.price;
        }
        uint8 numberUnreadMessages;
        for((, Message message) : m_message) {
            if (!message.read) {
                numberUnreadMessages ++;
            }
        }
        sammaritOfPurchases = SammaritOfPurchases( numberPaidPurchases, numberUnPaidPurchases, totalAmountPurchases,numberUnreadMessages);
    }



    function clearingList() public override{
        tvm.accept();
        for(uint32 i = 1; i<=m_count;i++){
            delete m_purchase[i];
        }
        m_count = 0;
    }


    //MESSAGE______________________________________________

    function createMessages(string fromWhom,string messageText) public override{
        tvm.accept();
        flag_from_read == false;
        m_count_message++;
        m_message[m_count_message] = Message(m_count_message,fromWhom, messageText,false);
    }
    
    function clearingListMessages() public override{
        tvm.accept();
        for(uint32 i = 1; i<=m_count_message;i++){
            delete m_message[i];
        }
        m_count_message = 0;
    }

    function getMessages() public override returns (Message[] messages) {
        string fromWhom;
        string messageText;
        bool read;
        tvm.accept();
        for(uint32 i = 1; i<=m_count_message;i++){
            m_message[i].read = true;
        }
        for((uint32 id, Message message) : m_message) {
            fromWhom = message.fromWhom;
            messageText = message.messageText;
            read = message.read;
            messages.push(Message(id, fromWhom, messageText,read)); 
       }
    }
}

