
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

// This is class that describes you smart contract.
struct Purchase{
    uint32 id;
    string name;
    uint32 count;
    uint32 price;
    uint64 timePurchase;
    bool isDone;
    
}
struct SammaritOfPurchases {
    uint32 numberPaidPurchases;
    uint32 numberUnpaidPurchases;
    uint32 totalAmountPurchases;
}
interface IntShoppingList {
    function createPurchase(string title,uint32 count) external;
    function BuyProduct(uint32 id, uint32 price) external;
    function deletePurchase(uint32 id) external;
    function getPurchases() external returns (Purchase[] purchases);
    function getSammaritOfPurchases() external returns (SammaritOfPurchases);
    function clearingList() external;
    
}

interface Transactable {
    function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
}
abstract contract AShoppingList {
   constructor(uint256 pubkey) public {}
}
