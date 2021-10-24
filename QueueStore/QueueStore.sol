
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract QueueStore {

    string[] lines;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();

    }
    modifier cheakOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        _;
    }
    function addLine(string s) public cheakOwnerAndAccept returns(string[]){
        lines.push(s);
        return lines;
    }
    
    function CallTheNext() public cheakOwnerAndAccept returns(string[]){
        for (uint i = 0; i<lines.length-1; i++){
            lines[i] = lines[i+1];
        }
        lines.pop();
        return lines;
    }
}
