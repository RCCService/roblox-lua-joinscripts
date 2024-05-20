-- Prepended to GroupBuild.lua and Join.lua
-- local startTime = tick()
local loadResolved = false
local joinResolved = false
local playResolved = true
local playStartTime = 0
local cdnSuccess = 0
local cdnFailure = 0
function reportContentProvider(time, queueLength, blocking)
pcall(function()
game:HttpGet("{17}/Analytics/ContentProvider.ashx?t=" .. time .. "&ql=" .. queueLength, blocking)
end)
end
function reportCdn(blocking)
pcall(function()
local newCdnSuccess = settings().Diagnostics.CdnSuccessCount
local newCdnFailure = settings().Diagnostics.CdnFailureCount
local successDelta = newCdnSuccess - cdnSuccess
local failureDelta = newCdnFailure - cdnFailure
cdnSuccess = newCdnSuccess
cdnFailure = newCdnFailure
if successDelta > 0 or failureDelta > 0 then
game:HttpGet("{17}/Game/Cdn.ashx?source=client&success=" .. successDelta .. "&failure=" .. failureDelta, blocking)
end
end)
end
function reportDuration(category, result, duration, blocking)
pcall(function()
game:HttpGet("{17}/Game/JoinRate.ashx?i={7}&c=" .. category .. "&r=" .. result .. "&d=" .. (math.floor(duration*1000)), blocking)
end)
end -- arguments ---------------------------------------
local threadSleepTime = ... if threadSleepTime==nil then
threadSleepTime = 15
end
local test = {16}
print("! Joining game '{12}' place {13} at {1}")
local closeConnection = game.Close:connect(function() if {0} then reportCdn(true) if (not loadResolved) or (not joinResolved) then
local duration = tick() - startTime; if not loadResolved then
loadResolved = true
reportDuration("GameLoad","Cancel", duration, true)
end
if not joinResolved then
joinResolved = true
reportDuration("GameJoin","Cancel", duration, true)
end
elseif not playResolved then
local duration = tick() - playStartTime; playResolved = true
reportDuration("GameDuration","Success", duration, true) end end end)
game:GetService("ChangeHistoryService"):SetEnabled(false)
game:GetService("ContentProvider"):SetThreadPool(16)
game:GetService("InsertService"):SetBaseCategoryUrl("{17}/Game/Tools/InsertAsset.ashx?nsets=10&type=base")
game:GetService("InsertService"):SetUserCategoryUrl("{17}/Game/Tools/InsertAsset.ashx?nsets=20&type=user&userid=%d")
game:GetService("InsertService"):SetCollectionUrl("{17}/Game/Tools/InsertAsset.ashx?sid=%d")
game:GetService("InsertService"):SetAssetUrl("{17}/Asset/?id=%d")
game:GetService("InsertService"):SetAssetVersionUrl("{17}/Asset/?assetversionid=%d")
game:GetService("InsertService"):SetAdvancedResults({19})
local waitingForCharacter = false
local waitingForCharacterGuid = '{15}'; pcall( function() if settings().Network.MtuOverride == 0 then
settings().Network.MtuOverride = 1400
end
end)
client = game:GetService("NetworkClient")
visit = game:GetService("Visit")
function setMessage(message)
game:SetMessage(message)
end
function showErrorWindow(message, errorType)
if {0} then
if (not loadResolved) or (not joinResolved) then
local duration = tick() - startTime; if not loadResolved then
loadResolved = true
reportDuration("GameLoad","Failure", duration, false)
end
if not joinResolved then
joinResolved = true
reportDuration("GameJoin","Failure", duration, false)
end
pcall(function() game:HttpGet("{14}?FilterName=Type&FilterValue=" .. errorType .. "&Type=JoinFailure", false)
end)
elseif not playResolved then
local duration = tick() - playStartTime; playResolved = true reportDuration("GameDuration","Failure", duration, false)
pcall(function() game:HttpGet("{14}?FilterName=Type&FilterValue=" .. errorType .. "&Type=GameDisconnect", false)
end)
end
end
game:SetMessage(message)
end
function stat(typeID)
if not test then
pcall(function() game:HttpGet("{6}&TypeID=" .. typeID, false)
end)
end
end
function analytics(name)
if not test and {20} then
pcall(function()
game:HttpGet("{14}?IPFilter=Primary&SecondaryFilterName=UserId&SecondaryFilterValue={7}&Type=" .. name, false)
end)
end
end
function analyticsGuid(name, guid)
if not test and {20} then
pcall(function()
game:HttpGet("{14}?IPFilter=Primary&SecondaryFilterName=guid&SecondaryFilterValue=" .. guid .. "&Type=" .. name, false)
end)
end
end
function reportError(err, message) print("***ERROR*** " .. err)
if not test then
visit:SetUploadUrl("")
end
client:Disconnect()
wait(4)
showErrorWindow("Error: " .. err, message)
end
function onDisconnection(peer, lostConnection)
if lostConnection then
if waitingForCharacter then
analyticsGuid('Waiting for Character Lost Connection',waitingForCharacterGuid)
end
showErrorWindow("You have lost the connection to the game", "LostConnection")
else
if waitingForCharacter then
analyticsGuid('Waiting for Character Game Shutdown',waitingForCharacterGuid)
end
showErrorWindow("This game has shut down", "Kick")
end
end
function requestCharacter(replicator)
connection = player.Changed:connect(function (property)
if property=="Character" then
game:ClearMessage()
waitingForCharacter = false
analyticsGuid("Waiting for Character Success", waitingForCharacterGuid) connection:disconnect()
if {0} then
if not joinResolved then
local duration = tick() - startTime; joinResolved = true
reportDuration("GameJoin","Success", duration, false) playStartTime = tick()
playResolved = false
end
end
end
end)
setMessage("Requesting character")
if {0} and not loadResolved then
local duration = tick() - startTime; loadResolved = true
reportDuration("GameLoad","Success", duration, false)
end
local success, err = pcall(function()
replicator:RequestCharacter()
setMessage("Waiting for character")
waitingForCharacter = true
analyticsGuid('Waiting for Character Begin',waitingForCharacterGuid); end)
if not success then
reportError(err,"W4C")
return end end
function onConnectionAccepted(url, replicator)
local waitingForMarker = true
local success, err = pcall(function()
if not test then
visit:SetPing("{3}", {4}) stat(5)
end
game:SetMessageBrickCount()
replicator.Disconnection:connect(onDisconnection)
local marker = replicator:SendMarker()
marker.Received:connect(function()
waitingForMarker = false
requestCharacter(replicator)
end)
end)
if not success then
reportError(err,"ConnectionAccepted")
return end
while waitingForMarker do
workspace:ZoomToExtents()
wait(0.5)
end
end
function onConnectionFailed(_, error)
showErrorWindow("Failed to connect to the Game. (ID=" .. error .. ")", "ID" .. error)
end
function onConnectionRejected()
connectionFailed:disconnect()
showErrorWindow("This game is not available. Please try another", "WrongVersion")
end
idled = false
function onPlayerIdled(time)
if time > 20*60 then
showErrorWindow(string.format("You were disconnected for being idle %d minutes", time/60), "Idle") client:Disconnect()
if not idled then
idled = true
end
end
end
analytics('Start Join Script')
pcall(function()
settings().Diagnostics:LegacyScriptMode()
end)
local success, err = pcall(function()
game:SetRemoteBuildMode(true)
setMessage("Creating Player")
player = game:GetService("Players"):CreateLocalPlayer({7})
player:SetSuperSafeChat({8})
player.Idled:connect(onPlayerIdled)
onPlayerAdded(player)
pcall(function()
player.Name = [========[{5}]========]
end)
player.CharacterAppearance = "{9}"
if not test then
visit:SetUploadUrl("")
end
analytics('Created Player')
setMessage("Connecting to Server")
client.ConnectionAccepted:connect(onConnectionAccepted)
client.ConnectionRejected:connect(onConnectionRejected)
connectionFailed = client.ConnectionFailed:connect(onConnectionFailed)
client.Ticket = "{10}"
client:Connect("{1}", {2}, {0}, threadSleepTime)
analytics('Connect Client')
end)
if not success then
reportError(err,"CreatePlayer")
end
if not test then
loadfile("{11}")("{12}", {13})
end if {0} then
delay(60*5,
function()
while true do
reportCdn(false)
wait(60*5)
end
end)
local cpTime = 30
delay(cpTime, function()
while cpTime <= 480 do
reportContentProvider(cpTime, game:GetService("ContentProvider").RequestQueueSize, false)
wait(cpTime)
cpTime = cpTime * 2
end
end)
end
analytics('Join Finished')