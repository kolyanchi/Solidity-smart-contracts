
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
import "MilitaryUnit.sol";
import "GameObject.sol";
import "BaseStation.sol";
import "GameObjectInterface.sol";

contract Warrior is MilitaryUnit{
    constructor(BaseStation base) MilitaryUnit(base) public {
        attack = 4;
        protection = 2;
    }
    // function GetAttack(uint attackPower) virtual public override pay returns (uint){
    //     attack = attackPower;
    //     return attack;
    // }
    // function GetProtection(uint protectionPower) virtual public override pay returns (uint){
    //     protection = protectionPower;
    //     return protection;
    // }
    

}



