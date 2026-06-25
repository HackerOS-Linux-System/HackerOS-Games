local CONTRACT_POOL = {
    {name="Weather Satellite Deploy",  type="SatelliteNetwork", payout=30, rep=3,  deadline=6,  desc="Deploy 3-satellite weather constellation"},
    {name="Military Reconnaissance",   type="SatelliteNetwork", payout=50, rep=0,  deadline=8,  desc="Classified recon payload — no publicity"},
    {name="Orbital Science Lab",       type="CrewedOrbit",      payout=40, rep=6,  deadline=10, desc="12-day microgravity research mission"},
    {name="Lunar Soil Sample Return",  type="LunarLanding",     payout=90, rep=15, deadline=24, desc="Return 1kg of regolith from Mare Tranquillitatis"},
    {name="Mars Climate Study",        type="MarsProbe",        payout=60, rep=10, deadline=18, desc="Atmospheric entry & surface weather data"},
    {name="Commercial Crew Transport", type="CrewedOrbit",      payout=35, rep=5,  deadline=6,  desc="Ferry 4 crew to international station"},
    {name="Deep Space Observatory",    type="DeepSpaceProbe",   payout=75, rep=12, deadline=36, desc="Jupiter/Saturn flyby sensor package"},
    {name="Asteroid Resource Survey",  type="AsteroidProbe",    payout=55, rep=8,  deadline=20, desc="Spectral analysis of Ryugu-class NEA"},
    {name="Venus Atmosphere Probe",    type="VenusProbe",       payout=65, rep=10, deadline=18, desc="Entry probe surviving 45 seconds in cloud layer"},
    {name="Orbital Hotel Module",      type="SpaceStation",     payout=120,rep=20, deadline=48, desc="Launch & dock luxury cabin module"},
}

function generateContracts(a, n)
    a.contracts = a.contracts or {}
    -- Remove expired/completed
    local keep = {}
    for _, c in ipairs(a.contracts) do
        if c.status == "Open" then table.insert(keep, c) end
    end
    a.contracts = keep
    -- Add up to n new contracts
    local available = {}
    for _, cp in ipairs(CONTRACT_POOL) do
        local found = false
        for _, c in ipairs(a.contracts) do if c.name == cp.name then found=true; break end end
        if not found then table.insert(available, cp) end
    end
    while #a.contracts < n and #available > 0 do
        local idx = math.random(#available)
        local cp  = table.remove(available, idx)
        local c   = {}
        for k,v in pairs(cp) do c[k]=v end
        c.status       = "Open"
        c.months_left  = c.deadline
        table.insert(a.contracts, c)
    end
end

function tickContracts(a, gs)
    if not a.contracts then return end
    for _, c in ipairs(a.contracts) do
        if c.status == "Open" then
            c.months_left = c.months_left - 1
            if c.months_left <= 0 then
                c.status = "Expired"
                a.reputation = clamp(a.reputation - 2, 0, 100)
                pushNotification(gs, "Contract expired: " .. c.name)
            end
        end
    end
end

function completeContract(a, gs, mission_type)
    if not a.contracts then return end
    for _, c in ipairs(a.contracts) do
        if c.status == "Open" and c.type == mission_type then
            c.status     = "Complete"
            a.budget     = a.budget + c.payout
            a.reputation = clamp(a.reputation + c.rep, 0, 100)
            pushNotification(gs, "Contract complete: " .. c.name .. " (+$" .. c.payout .. "M)")
            return
        end
    end
end
