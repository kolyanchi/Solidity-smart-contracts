Debots for making a shopping list (product names, quantity, price) and the ability to mark already purchased goods

UPDATE: 
Added methods for writing and viewing messages
Added a MamaDebot that can view the shopping list at the address and leave messages there.

Basic smart contract:
ShoppingList.sol
Interface for the Debot:
IntShoppingList.sol
Basic abstract contract-debot initialization of the list:
InitializingListDebot.sol
The first subsidiary contract-debot: 
FillingShoppingListDebot.sol
(net.ton.dev 0:d12e47710e4b6ee54b49c250e67386b7228f04fd8e9dd7e02b6c09275226278b)
The second subsidiary contract-debot:
ShoppingDebot.sol
(net.ton.dev 0:2ed0429c71cd7106f5cc9a37fc1c66b785d802ba3dbb034adf6375ba49573532)

The Debot of viewing and writing messages: 
MamaDebot.sol 
(net.ton.dev 0:06edf685842d667766e485669cd7c6c3b85ce3c4a2f9047a655e53c455a0bd1c)
