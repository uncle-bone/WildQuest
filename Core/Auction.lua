local _, ns = ...
ns.Auction = { pending = false, query = "", results = {}, eventAvailable = false,
    lastMessage = "Enter an item name, open the Auction House, then scan." }
function ns.Auction:Initialize()
    local frame = ns.EventFrame
    if frame and type(frame.RegisterEvent) == "function" then
        self.eventAvailable = pcall(frame.RegisterEvent, frame, "AUCTION_ITEM_LIST_UPDATE")
    end
    if not self.eventAvailable then
        self.lastMessage = "Auction House scanning is unavailable: this client does not support AUCTION_ITEM_LIST_UPDATE."
    end
end
function ns.Auction:Scan(query)
    query = tostring(query or ""):match("^%s*(.-)%s*$")
    if query == "" then return false, "enter an item name to search" end
    if not self.eventAvailable then
        return false, "Auction House result events are unavailable on this client build"
    end
    if type(QueryAuctionItems) ~= "function" then
        return false, "Auction House search is not exposed by this client build"
    end
    self.query, self.pending, self.results = query, true, {}
    self.lastMessage = "Auction House search requested for " .. query
    local ok = pcall(QueryAuctionItems, query, nil, nil, nil, nil, nil, 0, nil, nil, false)
    if not ok then self.pending = false; return false, "client rejected the Auction House search" end
    return true
end
function ns.Auction:HandleEvent(event)
    if event ~= "AUCTION_ITEM_LIST_UPDATE" or not self.pending then return end
    self.pending = false
    if type(GetNumAuctionItems) ~= "function" or type(GetAuctionItemInfo) ~= "function" then
        self.lastMessage = "Auction House results arrived, but listing details are unavailable."
        return
    end
    local count = tonumber(GetNumAuctionItems("list")) or 0
    local cheapest = {}
    for index = 1, count do
        local name, _, stack, _, _, _, _, _, buyout, _, _, _, _, itemID = GetAuctionItemInfo("list", index)
        buyout, stack = tonumber(buyout) or 0, tonumber(stack) or 1
        if buyout > 0 then
            local unitPrice = buyout / math.max(1, stack)
            local row = cheapest[itemID or name]
            if not row or unitPrice < row.unitPrice then
                local link = type(GetAuctionItemLink) == "function" and GetAuctionItemLink("list", index) or nil
                cheapest[itemID or name] = { name = name or self.query, itemID = itemID,
                    link = link, buyout = buyout, stack = stack, unitPrice = unitPrice }
            end
        end
    end
    for _, row in pairs(cheapest) do self.results[#self.results + 1] = row end
    table.sort(self.results, function(a, b) return a.unitPrice < b.unitPrice end)
    self.lastMessage = #self.results > 0 and ("Found " .. #self.results .. " item listings for " .. self.query)
        or ("No buyout listings found for " .. self.query)
    local data = ns:GetCharacterDB()
    data.auctionNotes = type(data.auctionNotes) == "table" and data.auctionNotes or {}
    data.auctionNotes[self.query] = { scannedAt = time and time() or 0, results = self.results }
end
