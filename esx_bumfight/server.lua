ESX = nil

local bluePlayer = nil
local redPlayer = nil
local queuePlayer = nil
local bluePlayerReady = false
local redPlayerReady = false
local bluePlayerWin = 1
local redPlayerWin = 1
local waitPlayerReady = false
local waitNextRound = false
local fightStarted = false
local canBet = false
local totalBetOnBlue = 0
local totalBetOnRed = 0
local rewardBlue = 0
local rewardRed = 0
local Bets = {}

TriggerEvent(
    'esx:getSharedObject',
    function(obj)
        ESX = obj
    end
)

ESX.RegisterServerCallback(
    'bumfight:wanted',
    function(source, cb)
        local _source = source
        local bettorName = GetPlayerName(_source)
        if (Bets[bettorName] == nil) or (Bets[bettorName].wanted == false) then
            cb(false)
        else
            TriggerClientEvent('esx:showNotification', _source, '~r~Tu es fou de te ramener ici, on va te buter!')
            TriggerClientEvent('bumfight:callGang')
            local xPlayers = ESX.GetPlayers()
            for i = 1, #xPlayers, 1 do
                local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
                if xPlayer.job.name == 'police' then
                    TriggerClientEvent('bumfight:setcopblip', xPlayers[i], 137.81, -1325.28, 29.2)
                end
            end
            cb(true)
        end
    end
)

RegisterServerEvent('bumfight:register')
AddEventHandler(
    'bumfight:register',
    function()
        local _source = source
        waitPlayerReady = true
        while waitPlayerReady do
            Wait(0)
            if bluePlayer == nil then
                bluePlayer = _source
                TriggerClientEvent('bumfight:gotoBlueCorner', bluePlayer)
            elseif (bluePlayer ~= nil) and (redPlayer == nil) then
                if (_source ~= bluePlayer) then
                    redPlayer = _source
                    TriggerClientEvent('bumfight:gotoRedCorner', redPlayer)
                end
            elseif (bluePlayer ~= nil) and (redPlayer ~= nil) and (queuePlayer == nil) then
                if (_source ~= bluePlayer) and (_source ~= redPlayer) then
                    queuePlayer = _source
                    TriggerClientEvent('esx:showNotification', queuePlayer, 'Attendez la fin du ~y~combat~w~, vous êtes le ~g~prochain~w~!')
                end
            elseif (bluePlayer ~= nil) and (redPlayer ~= nil) and (queuePlayer ~= nil) then
                if (_source ~= bluePlayer) and (_source ~= redPlayer) and (_source ~= queuePlayer) then
                    TriggerClientEvent('esx:showNotification', _source, "~r~J'ai déjà assez de combattant~w~, revenez au prochain ~y~combat~w~!")
                end
            elseif fightStarted then
                waitPlayerReady = false
            end
            if bluePlayerReady and redPlayerReady then
                TriggerClientEvent('bumfight:fightTimer', bluePlayer)
                TriggerClientEvent('bumfight:fightTimer', redPlayer)
                fightStarted = true
                bluePlayerReady = false
                redPlayerReady = false
                waitPlayerReady = false
            end
        end
    end
)

RegisterServerEvent('bumfight:blueReady')
AddEventHandler(
    'bumfight:blueReady',
    function()
        bluePlayerReady = true
    end
)

RegisterServerEvent('bumfight:redReady')
AddEventHandler(
    'bumfight:redReady',
    function()
        redPlayerReady = true
    end
)

RegisterServerEvent('bumfight:nextFighter')
AddEventHandler(
    'bumfight:nextFighter',
    function()
        local _source = source
        fightStarted = false
        if _source == bluePlayer then
            payement('red')
            --redPayement()
            redReward()
            --rewardRed = (totalBetOnRed / 10) * redPlayerWin
            --reward(rewardRed, redPlayer, totalBetOnRed)
            nextBlue()
        elseif _source == redPlayer then
            payement('blue')
            --bluePayement()
            blueReward()
            --rewardBlue = (totalBetOnBlue / 10) * bluePlayerWin
            --reward(rewardBlue, bluePlayer, totalBetOnBlue)
            nextRed()
        end
        if (redPlayer ~= nil) and (bluePlayer ~= nil) then
            nextRound()
        end
        totalBetOnBlue = 0
        totalBetOnRed = 0
    end
)

function nextBlue()
    if redPlayer ~= nil then
        TriggerClientEvent('bumfight:looser', bluePlayer)
        TriggerClientEvent('bumfight:winner', redPlayer)
        bluePlayer = nil
        bluePlayerWin = 1
        redPlayerWin = redPlayerWin + 1
        if queuePlayer ~= nil then
            queuePlayer = bluePlayer
        else
            TriggerClientEvent('esx:showNotification', redPlayer, '~r~Plus personne ne veut se battre contre toi!')
            TriggerClientEvent('bumfight:noMoreFighter', redPlayer)
            redPlayer = nil
        end
    end
end

function nextRed()
    if bluePlayer ~= nil then
        TriggerClientEvent('bumfight:looser', redPlayer)
        TriggerClientEvent('bumfight:winner', bluePlayer)
        redPlayer = nil
        redPlayerWin = 1
        bluePlayerWin = bluePlayerWin + 1
        if queuePlayer ~= nil then
            queuePlayer = redPlayer
        else
            TriggerClientEvent('esx:showNotification', bluePlayer, '~r~Plus personne ne veut se battre contre toi!')
            TriggerClientEvent('bumfight:noMoreFighter', bluePlayer)
            bluePlayer = nil
        end
    end
end

function nextRound()
    waitNextRound = true
    while waitNextRound do
        Wait(0)
        TriggerClientEvent('bumfight:gotoBlueCorner', bluePlayer)
        TriggerClientEvent('bumfight:gotoRedCorner', redPlayer)
        if bluePlayerReady and redPlayerReady then
            TriggerClientEvent('bumfight:fightTimer', bluePlayer)
            TriggerClientEvent('bumfight:fightTimer', redPlayer)
            fightStarted = true
            bluePlayerReady = false
            redPlayerReady = false
            waitNextRound = false
        end
    end
end

RegisterServerEvent('bumfight:canBet')
AddEventHandler(
    'bumfight:canBet',
    function(closestPlayer)
        local bettors = closestPlayer
        if bettors ~= bluePlayer and bettors ~= redPlayer then
            TriggerClientEvent('bumfight:canBet', bettors)
        end
        canBet = true
    end
)

RegisterServerEvent('bumfight:cantBet')
AddEventHandler(
    'bumfight:cantBet',
    function(closestPlayer)
        local bettors = closestPlayer
        if bettors ~= bluePlayer and bettors ~= redPlayer then
            TriggerClientEvent('bumfight:cantBet', bettors)
        end
        canBet = false
    end
)

ESX.RegisterServerCallback(
    'bumfight:betOpen',
    function(source, cb)
        if canBet then
            cb(true)
        else
            cb(false)
        end
    end
)

RegisterServerEvent('bumfight:bet')
AddEventHandler(
    'bumfight:bet',
    function(betAmount, betOnFighter)
        local _source = source
        local xPlayer = ESX.GetPlayerFromId(_source)
        local bettorName = GetPlayerName(_source)
        local betWin = 0
        if (Bets[bettorName] == nil) then
            local payement = 0
            local score = 0
            if betOnFighter == 'blue' then
                totalBetOnBlue = totalBetOnBlue + betAmount
                betWin = betAmount + (betAmount / bluePlayerWin)
                registerBet(bettorName, _source, betWin, payement, score, betOnFighter)
                TriggerClientEvent('esx:showNotification', _source, 'Votre ~g~pari~w~ a été enregistré!')
                TriggerClientEvent('esx:showNotification', bluePlayer, 'Un ~g~pari~w~ a été enregistré sur vous!')
				xPlayer.removeMoney(betAmount)
            elseif betOnFighter == 'red' then
                totalBetOnRed = totalBetOnRed + betAmount
                betWin = betAmount + (betAmount / redPlayerWin)
                registerBet(bettorName, _source, betWin, payement, score, betOnFighter)
                TriggerClientEvent('esx:showNotification', _source, 'Votre ~g~pari~w~ a été enregistré!')
                TriggerClientEvent('esx:showNotification', redPlayer, 'Un ~g~pari~w~ a été enregistré sur vous!')
				xPlayer.removeMoney(betAmount)
            end
        elseif (Bets[bettorName] ~= nil) and (Bets[bettorName].bet == 0) then
            local payement = Bets[bettorName].payement
            local score = Bets[bettorName].score
            if betOnFighter == 'blue' then
                totalBetOnBlue = totalBetOnBlue + betAmount
                betWin = betAmount + (betAmount / bluePlayerWin)
                registerBet(bettorName, _source, betWin, payement, score, betOnFighter)
                TriggerClientEvent('esx:showNotification', _source, 'Votre ~g~pari~w~ a été enregistré!')
                TriggerClientEvent('esx:showNotification', bluePlayer, 'Un ~g~pari~w~ a été enregistré sur vous!')
				xPlayer.removeMoney(betAmount)
            elseif betOnFighter == 'red' then
                totalBetOnRed = totalBetOnRed + betAmount
                betWin = betAmount + (betAmount / redPlayerWin)
                registerBet(bettorName, _source, betWin, payement, score, betOnFighter)
                TriggerClientEvent('esx:showNotification', _source, 'Votre ~g~pari~w~ a été enregistré!')
                TriggerClientEvent('esx:showNotification', redPlayer, 'Un ~g~pari~w~ a été enregistré sur vous!')
				xPlayer.removeMoney(betAmount)
            end
        else
            TriggerClientEvent('esx:showNotification', _source, '~r~Vous avez déjà parié!')
        end
    end
)

RegisterServerEvent('bumfight:givePayement')
AddEventHandler(
    'bumfight:givePayement',
    function()
        local _source = source
        local xPlayer = ESX.GetPlayerFromId(_source)
        local sourceName = GetPlayerName(_source)
        if Bets[sourceName] == nil then
            TriggerClientEvent('esx:showNotification', _source, '~r~Vous n\'avez aucun pari à récupérer')
        end
        for i, val in pairs(Bets) do
            if val.player == _source then
                if val.score <= 3 then
                    TriggerClientEvent('esx:showNotification', _source, 'Vous avez gagné' .. val.payement .. '$')
                    xPlayer.addAccountMoney('black_money', val.payement)
                else
                    TriggerClientEvent('esx:showNotification', _source, '~r~T\'essayes de m\'anarquer? T\'es mort!')
                    TriggerClientEvent('bumfight:callGang')
                    val.wanted = true
                end
                val.payement = 0
            elseif val.payement == 0 then
                TriggerClientEvent('esx:showNotification', _source, '~r~Vous n\'avez aucun pari à récupérer')
            end
        end
    end
)

function registerBet(bettorName, _source, betWin, payement, score, betOnFighter)
    Bets[bettorName] = {
        player = _source,
        bet = betWin,
        payement = payement,
        score = score,
        betOn = betOnFighter,
        wanted = false
    }
end

--[[function bluePayement()
    for i, val in pairs(Bets) do
        if val.betOn == 'blue' then
            val.payement = val.payement + val.bet
            if val.bet >= 10000 then
                val.score = val.score + 1
            end
            val.bet = 0
        end
        if val.betOn == 'red' then
            val.score = 0
        end
    end
end

function redPayement()
    for i, val in pairs(Bets) do
        if val.betOn == 'red' then
            val.payement = val.payement + val.bet
            if val.bet >= 10000 then
                val.score = val.score + 1
            end
            val.bet = 0
        end
        if val.betOn == 'blue' then
            val.score = 0
        end
    end
end]]

function payement(side)
    for i, val in pairs(Bets) do
        if val.betOn == side then
            val.payement = val.payement + val.bet
            if val.bet >= 5000 then
                val.score = val.score + 1
            end
            val.bet = 0
        end
        if val.betOn ~= side then
            val.score = 0
        end
    end
end

--[[function reward(reward, player, totalBet)
    local xPlayer = ESX.GetPlayerFromId(player)
    if totalBet > 0 then
        xPlayer.addAccountMoney('black_money', reward)
    else
        TriggerClientEvent('esx:showNotification', player, "Il y n'avait aucun pari sur vous, ~r~vous n'avez rien gagné!")
    end
end]]


function blueReward()
    local xPlayer = ESX.GetPlayerFromId(bluePlayer)
    if totalBetOnBlue > 0 then
        local betOnBlue = totalBetOnBlue / 10
        rewardBlue = betOnBlue * bluePlayerWin
        xPlayer.addAccountMoney('black_money', rewardBlue)
        TriggerClientEvent('esx:showNotification', bluePlayer, "Vous avez gagné ~g~"..rewardBlue.."~w~ $")
    else
        TriggerClientEvent('esx:showNotification', bluePlayer, "Il y n'avait aucun pari sur vous, ~r~vous n'avez rien gagné!")
    end
end

function redReward()
    local xPlayer = ESX.GetPlayerFromId(redPlayer)
    if totalBetOnRed > 0 then
        local betOnRed = totalBetOnRed / 10
        rewardRed = betOnRed * redPlayerWin
        xPlayer.addAccountMoney('black_money', rewardRed)
        TriggerClientEvent('esx:showNotification', redPlayer, "Vous avez gagné ~g~"..rewardRed.."~w~ $")
    else
        TriggerClientEvent('esx:showNotification', redPlayer, "Il y n'avait aucun pari sur vous, ~r~vous n'avez rien gagné!")
    end
end