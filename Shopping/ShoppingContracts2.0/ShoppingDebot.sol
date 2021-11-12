pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'InitializingListDebot.sol';

contract AddingListDebot is InitializingListDebot{
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Shopping with a list";
        version = "0.2.0";
        publisher = "Gipp Nikolay with the support of TON Labs";
        key = "Shopping list manager";
        author = "Gipp Nikolay";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, i'm a Shopping DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }
    
    function _menu() public override{
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You bought {} products, there are {} left to buy (you spent {}$)\n Unread messages: {}",
                    m_sammaritOfPurchases.numberPaidPurchases,
                    m_sammaritOfPurchases.numberUnpaidPurchases,
                    m_sammaritOfPurchases.totalAmountPurchases,
                    m_sammaritOfPurchases.numberUnreadMessages
            ),
            sep,
            [
                MenuItem("Show shopping list","",tvm.functionId(showPurchasesBot)),
                MenuItem("Make a purchase","",tvm.functionId(MakePurchaseBot)),
                MenuItem("Show recent messages","",tvm.functionId(showMessages))
            ]
        );
    }
    

    function MakePurchaseBot(uint32 index) public {
        index = index;
        if (m_sammaritOfPurchases.numberPaidPurchases + m_sammaritOfPurchases.numberUnpaidPurchases > 0) {
            Terminal.input(tvm.functionId(MakePurchase_), "Enter purchase number:", false);
        } else {
            Terminal.print(0, "Sorry, you don't have any scheduled purchases");
            _menu();
        }
    }

    function MakePurchase_(string value) public {
        (uint256 num,) = stoi(value);
        m_purchaseId = uint32(num);
        Terminal.input(tvm.functionId(MakePurchase__), "Enter the purchase price:", false);

    }
    function MakePurchase__(string value) public {
        (uint256 num,) = stoi(value);
        m_purchasePrice = uint32(num);
        optional(uint256) pubkey = 0;
        IntShoppingList(m_address).BuyProduct{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_purchaseId, m_purchasePrice);
    }



} 