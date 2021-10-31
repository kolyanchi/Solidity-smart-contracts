
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
import "GameObjectInterface.sol";

contract GameObject is GameObjectInterface{
    int public health = 5;
    int public protection = 1;
    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }
    modifier pay() {
        tvm.accept();
        _;
    }
    //GameObjectInterface addres,
    function AcceptAttack(int attack) virtual external pay override{
        health -= (attack-protection);
        if (CheckingLife() == false){
            sendAllMoneyAndDestroyAccount(msg.sender);
        }
    }
    function CheckingLife() private pay returns (bool) {
        if(health > 0){
            return true;
        } 
        else{
            return false;
        }
    }
    function sendAllMoneyAndDestroyAccount(address dest) public pay {
        dest.transfer(1, true, 160);
    }
    function GetProtection() virtual public pay returns (int){
        return protection;
    }
    function SetProtection(int protectionPower) virtual public pay{
        protection = protectionPower;
    }
    function GetHealth() public pay returns (int){
        return health;
    }
    function SetHealth(int healthPower) public pay returns (int){
        health = healthPower;
    }
}