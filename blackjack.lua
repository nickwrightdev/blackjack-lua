-- Author: Nick Wright
--		   nick@nickwrightdev.com
--
-- This is a simple blackjack game played in the console

suits = {"Clubs", "Diamonds", "Hearts", "Spades"}
faces = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}

-- ---------- CARD ----------

Card = {suit = "Clubs", face = "2"}
Card.__index = Card

function Card:new (suit, face) 
	local c = {}
	setmetatable(c, Card)
	
	c.suit = suit;
	c.face = face;
	
	return c
end

function Card:print ()
	return self.face .. " of " .. self.suit
end

-- ---------- DECK ----------

Deck = {cards = {}}
Deck.__index = Deck

function Deck:new ()
	local d = {}
    setmetatable(d, Deck)
	
	d.cards = {}
	return d
end

function Deck:create () 
	
	self.cards = {}
	
	for i = 1, #suits, 1 do
		for j = 1, #faces, 1 do
			local card = Card:new(suits[i], faces[j])
			self.cards[#self.cards + 1] = card
		end
	end
end

function Deck:shuffle () 
	
	for i = 1, #self.cards, 1 do
		local j = math.random(1, #self.cards)
		self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
	end
end

function Deck:print ()
	
	for i = 1, #self.cards, 1 do
		print (self.cards[i]:print())
	end
end

-- ---------- PLAYER ----------

Player = {balance = 0, placedBet = 0}
Player.__index = Player

function Player:new ()
	local p = {}
	setmetatable(p, Player)
	
	p.balance = 0
	p.placedBet = 0
	
	return p
end

function Player:creditBalance (amount) 
	self.balance = self.balance + amount;
end

function Player:deductBalance (amount)
	self.balance = ((self.balance - amount) >= 0) and self.balance - amount or 0;
end

function Player:canBet (amount)
	return amount <= self.balance
end

function Player:placeBet (amount) 
	
	if self:canBet(amount) then
		self.placedBet = amount
		self:deductBalance(amount)
		return true
	end
	
	return false
end

function Player:clearBet ()
	self.placedBet = 0
end

-- ---------- GAME -----------

Game = {player = {}, deck = {}}
Game.__index = Game;

function Game:new() 
	local g = {}
	setmetatable(g, Game)
	
	g.player = {}
	g.deck = {}
	
	return g
end

function Game:initGame () 
	
	math.randomseed(os.time())
	
	self.player = Player:new()
	self.deck = Deck:new()
	
	self:addToBalance()
end

function Game:addToBalance ()
	
	repeat 
		print ()
		print("How much money are you adding to your balance?")
		money = io.read()
	until tonumber(money) ~= nil and tonumber(money) > 0
	
	self.player:creditBalance(tonumber(money))
	self:placeBet()
end

function Game:placeBet ()
	
	self.player:clearBet()
	
	repeat
		print ()
		placeBetStr = "You have $" .. self.player.balance .. ".  How much will you bet?"
		print(placeBetStr)
		betInput = io.read()
		bet = tonumber(betInput)
	until bet ~= nil and bet > 0 and self.player:canBet(bet)
	
	if self.player:placeBet (bet) then
		self:deal()
	end
end

function Game:deal ()
	
	betStr = "Let's play a round of Blackjack! You've bet $" .. self.player.placedBet
	print ()
	print (betStr)
	
	self.deck:create()
	self.deck:shuffle()
	--self.deck:print()
	
	-- deal cards
	
	self:evaluateDeal ()
	
end

function Game:evaluateDeal ()
	
	print()
	print("Player has ");
	print("Dealer shows a ");
	
	-- resolve game if player or dealer has blackjack
	-- self:resolveGame ()
	
	self:playerAction ()
	
end

function Game:playerAction ()
	
	-- if bust
	--self:dealerAction()
	
	-- if blackjack
	--self:dealerAction()
	
	print()
	print("Hit or Stand?")
	
	-- if stand
	self:playerStand ()
	
	-- if hit
	--self:playerHit()
end

function Game:playerStand ()
	
	print ()
	print ("Player stands");
	
	self:dealerAction() 
end

function Game:playerHit ()
	
	-- deal card to player
	
	print("Player takes a card.")
	
	self:playerAction ()
		
end

function Game:dealerAction ()
	
	-- if dealer blackjack
	--self:resolveGame ()
	
	-- if bust
	--self:resolveGame()
	
	-- if dealer stands
	--self:resovleGame()
	
	-- if dealer hits
	--self:dealerHit()
	
	self:resolveGame ()
	
end

function Game:dealerHit () 
	
	print ("Dealer takes a card.")
	
	-- if dealer blackjack
	--self:resolveGame ()
	
	-- if bust
	--self:resolveGame()
	
	-- if dealerStands
	--self:resolveGame()
	
end

function Game:resolveGame ()
	
	self:endGame()
end

function Game:endGame ()
	
	print()
	print("Thanks for playing!  Choose your next action:")
	print()
	print("  1 - Play Again")
	print("  2 - Add Money")
	print("  3 - Quit")
	
	userInput = io.read()
	
	if userInput == '1' then
		self:placeBet()
	elseif userInput == '2' then
		self:addToBalance()
	else
		os.exit(0)
	end		
end

-- ---------- MAIN ----------

game = Game:new()
game:initGame()

