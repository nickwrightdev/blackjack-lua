# blackjack-lua

I created this project as an exercise in learning Lua.  There are almost certainly better/proper ways to do things, and I intend to improve upon it as I learn more about development in Lua.

The game is playable from the console.   The rules are simple, but can be built upon in the future.

### The Basics
The player competes against the dealer.  The object of the game is to have a higher score than the dealer, without going over 21.  Face cards(J, K, Q) count are scored as 10, Aces are scored as either 11 or 1 and the rest of the cards are scored as their face value.   

This implementaion uses a single deck, but this can be changed in the future.

1. The player is asked to add money to their balance.
2. The player places a bet.
3. A new deck is created and shuffled before every deal.
4. The dealer deals 2 cards face up to the player, and 2 cards to herself - 1 face up and the other face down.
5. If the player and/or dealer has a 21, the game is over.   Otherwise, the player can either stand (end their turn) or hit as many times as desired until they stand or lose on a bust (score higher than 21).
6. After the player's turn, the dealer exposes her other card.  The dealer will hit on all scores below 17 and stand on all scores 17 and higher. 
7. If the player wins on any non-blackjack hand, they are paid 2 to 1.    Blackjack pays 3 to 2.
8. After a hand, the player can choose to leave the game.
9. Doubling down, splitting, and insurance are not implemented at this time.

### Credits
Developed by Nicholas A. Wright

### License
This project is released under the MIT License.   Refer to LICENSE.md for more information.

### Feedback
As I am still learning Lua, I am very open to constructive feedback.    Feedback can be left [here](https://github.com/nickwrightdev/blackjack-lua/issues/new).
