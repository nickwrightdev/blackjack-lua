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

-- ---------- MAIN -----------

math.randomseed(os.time())

deck = Deck:new()
deck:create()
deck:shuffle()
deck:print()