
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
import "MilitaryUnit.sol";

contract Archer is MilitaryUnit{
    constructor(BaseStation base) MilitaryUnit(base) public {}
    // function GetAttack(uint attackPower) virtual public override pay returns (uint){
    //     attack = attackPower;
    //     return attack;
    // }
    // function GetProtection(uint protectionPower) virtual public override pay returns (uint){
    //     protection = protectionPower;
    //     return protection;
    // }
}
