-- Author: Nick Wright
-- nick@nickwrightdev.com
--
-- This is a simple blackjack game played in the console
-- as an exercise in learning Lua.    
--

suits = 
{
    "Clubs", 
    "Diamonds", 
    "Hearts", 
    "Spades"
}
faces = 
{
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10", 
    "J", 
    "Q", 
    "K", 
    "A",
}

-- ---------- CARD ----------

Card = 
{
    suit = "Clubs", 
    face = "2"
}
Card.__index = Card

function Card:new(suit, face) 
    local c = {}
    setmetatable(c, Card)
    
    c.suit = suit;
    c.face = face;
	
    return c
end

function Card:ToString() 
    return self.face .. " of " .. self.suit
end

function Card:Print()
    print(self:tostring())
end

function Card:Score(busted)
	
    if (self.face == "K") or (self.face == "Q") or (self.face == "J") then
        return 10;
    elseif self.face == "A" then
        return (busted) and 1 or 11
    end

    return tonumber(self.face)
end

-- ---------- DECK ----------

Deck = 
{
    cards = {},
}
Deck.__index = Deck

function Deck:new()
    local d = {}
    setmetatable(d, Deck)
    
    d.cards = {}
    return d
end

function Deck:Create() 
	
    self.cards = {}
    
    for i = 1, #suits, 1 do
        for j = 1, #faces, 1 do
            local card = Card:new(suits[i], faces[j])
            self.cards[#self.cards + 1] = card
        end
    end
end

function Deck:Shuffle() 
	
    for i = 1, #self.cards, 1 do
        local j = math.random(1, #self.cards)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
end

function Deck:Print()
	
    for i = 1, #self.cards, 1 do
        print(self.cards[i]:tostring())
    end
end

function Deck:DealCard()
    
    local c = table.remove(self.cards, 1);
    return c
end

function Deck:PeekCard()
    return self.cards[1]
end

-- ---------- PLAYER ----------

Player = 
{
    balance = 0, 
    placedBet = 0,
}
Player.__index = Player

function Player:new()
    local p = {}
    setmetatable(p, Player)
	
    p.balance = 0
    p.placedBet = 0
	
    return p
end

function Player:CreditBalance(amount) 
    self.balance = self.balance + amount;
end

function Player:DeductBalance(amount)
    self.balance = ((self.balance - amount) >= 0) and self.balance - amount or 0;
end

function Player:CanBet(amount)
    return amount <= self.balance
end

function Player:PlaceBet(amount) 
	
    if self:CanBet(amount) then
        self.placedBet = amount
        self:DeductBalance(amount)
        return true
    end
    
    return false
end

function Player:ClearBet ()
    self.placedBet = 0
end

-- ---------- HAND ----------

Hand = 
{
    cards={}
}
Hand.__index = Hand

function Hand:new() 
    local h = {}
    setmetatable(h, Hand)
    
    h.cards = {}
    
    return h
end

function Hand:Clear() 
    self.cards = {}
end

function Hand:AddCard(card)
    if card ~= nil then
        self.cards[#self.cards + 1] = card 
    end
end

function Hand:Score() 
	
    local busted = false
    local score = 0
	
    for _, c in ipairs(self.cards) do
        score = score + c:Score(busted)
		
        if not busted then 			
            if score > 21 and c.face == "A" then
                busted = true
                score = score - c:Score(false) + c:Score(true)
            end
        end
    end
	
    return score
end

function Hand:HasBlackjack() 
    return self:Score() == 21
end

function Hand:HasBust()
    return self:Score() > 21
end

function Hand:ToString()
    handStr = '';
    for _,c in ipairs(self.cards) do
        handStr = handStr .. c:ToString() .. '  '
    end
    
    return handStr
end

function Hand:Print()
    print(self:ToString())
end

-- ---------- GAME -----------

Game = 
{
    player = {}, 
    deck = {}, 
    playerHand = {}, 
    dealerHand = {}
}
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

function Game:InitGame() 
	
    math.randomseed(os.time())
	
    self.player = Player:new()
    self.deck = Deck:new()
    self.playerHand = Hand:new()
    self.dealerHand = Hand:new()
	
    self:AddToBalance()
end

function Game:AddToBalance()
	
    repeat 
        print ()
        print("How much money are you adding to your balance?")
        money = io.read()
    until tonumber(money) ~= nil and tonumber(money) > 0
	
    self.player:CreditBalance(tonumber(money))
    self:PlaceBet()
end

function Game:PlaceBet()
	
    self.player:ClearBet()
	
    repeat
        print()
        placeBetStr = "You have $" .. self.player.balance .. ".  How much will you bet?"
        print(placeBetStr)
        betInput = io.read()
        bet = tonumber(betInput)
    until bet ~= nil and bet > 0 and self.player:CanBet(bet)
	
    if self.player:PlaceBet(bet) then
        self:Deal()
    end
end

function Game:Deal()
	
    betStr = "Let's play a round of Blackjack! You've bet $" .. self.player.placedBet
    print()
    print(betStr)
	
    -- new deck and shuffle
    self.deck:Create()
    self.deck:Shuffle()
    --self.deck:print()
	
	-- clear hands
    self.playerHand:Clear()
    self.dealerHand:Clear()
	
	-- deal cards
    self.playerHand:AddCard(self.deck:DealCard())
    self.dealerHand:AddCard(self.deck:DealCard())
    self.playerHand:AddCard(self.deck:DealCard())
    self.dealerHand:AddCard(self.deck:DealCard())
	
    self:EvaluateDeal()
	
end

function Game:EvaluateDeal()
	
    print()
    print("Player has ", self.playerHand:Score(), self.playerHand.cards[1]:ToString(), self.playerHand.cards[2]:ToString());
    print("Dealer shows a ", self.dealerHand.cards[1]:ToString());
	
	-- TODO: this would be a logical place to offer insurance if needed
	
	-- game ends if either player has a blackjack
    if self.playerHand:HasBlackjack() or self.dealerHand:HasBlackjack() then
        self:ResolveGame()
    else 
        self:PlayerAction()
    end	
end

function Game:PlayerAction()
	
    if self.playerHand:HasBust() then
        self:DealerAction()
        return;
    end
	
    if self.playerHand:HasBlackjack() then
        self:DealerAction()
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
        self:PlayerHit()
    else
        self:PlayerStand()
    end
end

function Game:PlayerStand()
	
    playerStandsOn = "Player stands on " .. self.playerHand:Score() .. '.'
	
    print()
    print(playerStandsOn);
	
    self:DealerAction() 
end

function Game:PlayerHit()
	
    card = self.deck:DealCard()
    self.playerHand:AddCard(card)
	
    playerHits = "Player hits for a " .. card:ToString() .. " and a score of " .. self.playerHand:Score() .. "."
	
    print()
    print(playerHits)
	
    self:playerAction ()
		
end

function Game:DealerAction()
	
    dealerHas = "Dealer has " .. self.dealerHand:ToString() .. " for a score of " .. self.dealerHand:Score() .. "."
	
    print()
    print(dealerHas)
	
    -- dealer stands on player bust
    if self.playerHand:HasBust() then
        self:ResolveGame()
        return
     end
	
    if self.dealerHand:HasBlackjack() then
        self:ResolveGame()
        return
    end
	
    if self.dealerHand:HasBust() then
        self:ResolveGame()
        return
    end
	
    dealerScore = self.dealerHand:Score()
	
    if dealerScore > 16 then
        self:DealerStand()
    else
        self:DealerHit()
    end
end

function Game:DealerStand ()
	
    dealerStandsOn = "Dealer stands on " .. self.dealerHand:Score() .. '.'
	
    print()
    print(dealerStandsOn)
	
    self:ResolveGame()
end

function Game:DealerHit() 
	
    card = self.deck:dealCard()
    self.dealerHand:addCard(card)
	
    dealerHits = "Dealer hits for a " .. card:ToString() .. " and a score of " .. self.dealerHand:Score() .. "."
	
    print()
    print(dealerHits)
	
    self:DealerAction()
end

function Game:ResolveGame()
	
    playerScore = self.playerHand:Score()
    dealerScore = self.dealerHand:Score()
	
    print()
    print("Player Hand: ", self.playerHand:ToString())
    print("Player has ", playerScore)
    print()
    print("Dealer Hand: ", self.dealerHand:ToString())
    print("Dealer has ", dealerScore)
	
    push = false
    win = false
	
    if self.dealerHand:HasBust() then
        win = true;
    elseif (not self.playerHand:HasBust()) and (playerScore > dealerScore) then
        win = true;
    elseif playerScore == dealerScore then
        push = true;
    end
	
    betAmount = self.player.placedBet
    winAmount = 0
    gameMessage = ''
	
    if (win) then
        if self.playerHand:HasBlackjack() then
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
        self.player:CreditBalance(winAmount)
    end
	
    print()
    print(gameMessage)
    print("Game Over!")
	
    self:EndGame()
end

function Game:EndGame()
	
    outputStr = "Thanks for playing!"
    print()
    print("Thanks for playing!  Choose your next action:")
    print()
    print("  1 - Play Again")
    print("  2 - Add Money")
    print("  3 - Cash Out")
	
    userInput = io.read()
	
    if userInput == '1' then
        self:PlaceBet()
    elseif userInput == '2' then
        self:AddToBalance()
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

-- TODO: it would be nice to use arguments to set a starting balance


game = Game:new()
game:InitGame()

