-- Author: Nick Wright
--		   nick@nickwrightdev.com
--
-- This is a simple blackjack game played in the console
-- as an exercise in learning Lua.    
--

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

function Card:tostring() 
    return self.face .. " of " .. self.suit
end

function Card:print ()
    print (self:tostring())
end

function Card:score (busted)
	
	if (self.face == "K") or (self.face == "Q") or (self.face == "J") then
		return 10;
	elseif self.face == "A" then
		return (busted) and 1 or 11
	end
	
	return tonumber(self.face)
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
		print (self.cards[i]:tostring())
	end
end

function Deck:dealCard ()
	
	local c = table.remove(self.cards, 1);
	return c
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

-- ---------- HAND ----------

Hand = {cards={}}
Hand.__index = Hand

function Hand:new() 
	local h = {}
	setmetatable(h, Hand)
	
	h.cards = {}
	
	return h
end

function Hand:clear() 
	self.cards = {}
end

function Hand:addCard(card)
	if card ~= nil then
		self.cards[#self.cards + 1] = card
	end
end

function Hand:score() 
	
	local busted = false
	local score = 0
	
	for _, c in ipairs(self.cards) do
		score = score + c:score(busted)
		
		if not busted then 			
			if score > 21 and c.face == "A" then
				busted = true
				score = score - c:score(false) + c:score(true)
			end
		end
	end
	
	return score
end

function Hand:hasBlackjack() 
	return self:score() == 21
end

function Hand:hasBust()
	return self:score() > 21
end

function Hand:tostring()
	handStr = '';
	for _,c in ipairs(self.cards) do
		handStr = handStr .. c:tostring() .. '  '
	end
	
	return handStr
end

function Hand:print()
    print(self:tostring())
end

-- ---------- GAME -----------

Game = {player = {}, deck = {}, playerHand = {}, dealerHand = {}}
Game.__index = Game;

function Game:new() 
	local g = {}
	setmetatable(g, Game)
	
	g.player = {}
	g.deck = {}
	g.playerHand = {}
	g.dealerHand = {}
	
	return g
end

function Game:initGame () 
	
	math.randomseed(os.time())
	
	self.player = Player:new()
	self.deck = Deck:new()
	self.playerHand = Hand:new()
	self.dealerHand = Hand:new()
	
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
	
	-- new deck and shuffle
	self.deck:create()
	self.deck:shuffle()
	--self.deck:print()
	
	-- clear hands
	self.playerHand:clear()
	self.dealerHand:clear()
	
	-- deal cards
	self.playerHand:addCard(self.deck:dealCard())
	self.dealerHand:addCard(self.deck:dealCard())
	self.playerHand:addCard(self.deck:dealCard())
	self.dealerHand:addCard(self.deck:dealCard())
	
	self:evaluateDeal ()
	
end

function Game:evaluateDeal ()
	
	print()
	print("Player has ", self.playerHand:score(), self.playerHand.cards[1]:tostring(), self.playerHand.cards[2]:tostring());
	print("Dealer shows a ", self.dealerHand.cards[1]:tostring());
	
	-- TODO: this would be a logical place to offer insurance if needed
	
	-- game ends if either player has a blackjack
	if self.playerHand:hasBlackjack() or self.dealerHand:hasBlackjack() then
		self:resolveGame()
	else 
		self:playerAction ()
	end	
end

function Game:playerAction ()
	
	if self.playerHand:hasBust() then
		self:dealerAction()
		return;
	end
	
	if self.playerHand:hasBlackjack() then
		self:dealerAction()
		return;
	end
	
	-- TODO: this would be a logical place to offer a split
	
	print()
	print("Hit or Stand?")
	print("  H - Hit")
	print("  S - Stand")
	
	repeat
		userInput = io.read()
		userInput = string.upper(userInput)
	until (userInput == "H") or (userInput == "S")
	
	if userInput == "H" then
		self:playerHit()
	else
		self:playerStand()
	end
end

function Game:playerStand ()
	
	playerStandsOn = "Player stands on " .. self.playerHand:score() .. '.'
	
	print ()
	print (playerStandsOn);
	
	self:dealerAction() 
end

function Game:playerHit ()
	
	card = self.deck:dealCard()
	self.playerHand:addCard(card)
	
	playerHits = "Player hits for a " .. card:tostring() .. " and a score of " .. self.playerHand:score() .. "."
	
	print()
	print(playerHits)
	
	self:playerAction ()
		
end

function Game:dealerAction ()
	
	dealerHas = "Dealer has " .. self.dealerHand:tostring() .. " for a score of " .. self.dealerHand:score() .. "."
	
	print()
	print(dealerHas)
	
	-- dealer stands on player bust
	if self.playerHand:hasBust() then
		self:resolveGame()
		return
	end
	
	if self.dealerHand:hasBlackjack() then
		self:resolveGame()
		return
	end
	
	if self.dealerHand:hasBust() then
		self:resolveGame()
		return
	end
	
	dealerScore = self.dealerHand:score()
	
	if dealerScore > 16 then
		self:dealerStand ()
	else
		self:dealerHit ()
	end
end

function Game:dealerStand ()
	
	dealerStandsOn = "Dealer stands on " .. self.dealerHand:score() .. '.'
	
	print()
	print (dealerStandsOn)
	
	self:resolveGame ()
end

function Game:dealerHit () 
	
	card = self.deck:dealCard()
	self.dealerHand:addCard(card)
	
	dealerHits = "Dealer hits for a " .. card:tostring() .. " and a score of " .. self.dealerHand:score() .. "."
	
	print ()
	print (dealerHits)
	
	self:dealerAction()
end

function Game:resolveGame ()
	
	playerScore = self.playerHand:score()
	dealerScore = self.dealerHand:score()
	
	print ()
	print ("Player Hand: ", self.playerHand:tostring())
	print ("Player has ", playerScore)
	print ()
	print ("Dealer Hand: ", self.dealerHand:tostring())
	print ("Dealer has ", dealerScore)
	
	push = false
	win = false
	
	if self.dealerHand:hasBust() then
		win = true;
	elseif (not self.playerHand:hasBust()) and (playerScore > dealerScore) then
		win = true;
	elseif playerScore == dealerScore then
		push = true;
	end
	
	betAmount = self.player.placedBet
	winAmount = 0
	gameMessage = ''
	
	if (win) then
		if self.playerHand:hasBlackjack() then
			-- Blackjack pays 3:2
			winAmount = 3 * betAmount / 2
			gameMessage = "You win on a Blackjack!  You win $" .. winAmount .. "."
		else
			-- All other winning hands pay 2:1
			winAmount = betAmount * 2
			gameMessage = "You win!  You win $" .. winAmount .. "."
		end
	elseif (push) then
		-- return bet to player on push
		winAmount = betAmount;
		gameMessage = "You pushed with the Dealer!"
	else
		gameMessage = "You Lose!"
	end
	
	-- pay the winner
	if winAmount > 0 then
		self.player:creditBalance(winAmount)
	end
	
	print ()
	print (gameMessage)
	print ("Game Over!")
	
	self:endGame()
end

function Game:endGame ()
	
	outputStr = "Thanks for playing!"
	print()
	print("Thanks for playing!  Choose your next action:")
	print()
	print("  1 - Play Again")
	print("  2 - Add Money")
	print("  3 - Cash Out")
	
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

-- helper function to add some delay between states
function wait(seconds)
	local start = os.time()
	repeat until os.time() > start + seconds
end

game = Game:new()
game:initGame()

