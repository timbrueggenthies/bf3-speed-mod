driverPoints = {}
votedPlayers = {}
activeVoting = true

function printVoting()
	local message = 'Voting:\n'
	for i=1,#availablePlayers do
		message = message .. '/' .. i .. ' ' .. availablePlayers[i].name .. ' (' .. driverPoints[i] .. ')\n'
	end
	ChatManager:SendMessage(message)
	print(message)
end

function createVoting()
	activeVoting = true
	
    availablePlayers = PlayerManager:GetPlayersByTeam(1)
	for i=1,#availablePlayers do
		driverPoints[i] = 0
	end
	printVoting()
end

function getVotingResult()
	local maxPoints = 0
	for i=1,#availablePlayers do
		if driverPoints[i] > maxPoints then
			maxPoints = driverPoints[i]
		end
	end
	winner = {}
	for i=1,#availablePlayers do
		if driverPoints[i] == maxPoints then
			winner[#winner] = availablePlayers[i]
		end
	end
	if #winner > 1 then
		winner[0] = winner[math.random(0, #winner - 1)]
	end
	ChatManager:SendMessage('Winner: ' .. winner[0].name)
end

Events:Subscribe('Level:Loaded', function(levelName, gameMode, round, roundsPerMap)
	createVoting()	
end)

Events:Subscribe('Player:TeamChange', function(player, team, squad)
    createVoting()
end)

Events:Subscribe('Player:Chat', function(player, recipientMask, message)
	if player == nil then
		return
	end
	
	if not activeVoting then
		return
	end

	local playerAlreadyVoted = false
	for _,playername in pairs(votedPlayers) do
	  if playername == player.name then
			playerAlreadyVoted = true
		break
	  end
	end
	
	if not playerAlreadyVoted then

		votedPlayers[#votedPlayers + 1] = player.name
	
		if string.match(message, '/1') then
			vote = 1
		elseif string.match(message, '/2') then
			vote = 2
		elseif string.match(message, '/3') then
			vote = 3
		elseif string.match(message, '/4') then
			vote = 4
		elseif string.match(message, '/5') then
			vote = 5
		else
			return
		end
		
		if vote > #availablePlayers then
			return
		end
		
		driverPoints[vote] = driverPoints[vote] + 1
		
		ChatManager:SendMessage(player.name .. ' voted for ' .. availablePlayers[vote].name)
		
		if #votedPlayers == #availablePlayers then
			ChatManager:SendMessage('All Players have voted!')
			getVotingResult()
			activeVoting = false
		end
		
	else
		ChatManager:SendMessage(player.name .. ' tried to vote multiple times...')
	end
end)