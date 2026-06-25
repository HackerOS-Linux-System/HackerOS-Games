local RESEARCH_TREE = {
    -- Tier 1 (always available)
    {name="Basic Avionics",       area="Electronics",       cost=8,  duration=3, desc="Improved guidance computers",                 tier=1, unlocks="avionics_1",     requires={}},
    {name="Solid Fuel Boosters",  area="PropulsionTech",    cost=10, duration=4, desc="SRBs reduce launch cost 10%",                 tier=1, unlocks="srb",            requires={}},
    {name="Navigation Accuracy",  area="Navigation",        cost=12, duration=4, desc="+10% mission success chance",                 tier=1, unlocks="nav_accuracy",   requires={}},
    {name="Heat Shielding",       area="Materials",         cost=9,  duration=3, desc="Improved ablative TPS",                       tier=1, unlocks="heat_shield",    requires={}},
    {name="Solar Panels",         area="PowerSystems",      cost=7,  duration=2, desc="Longer duration probe missions",              tier=1, unlocks="solar_power",    requires={}},
    -- Tier 2
    {name="Advanced Propulsion",  area="PropulsionTech",    cost=20, duration=6, desc="+5% mission success + heavier rockets",       tier=2, unlocks="propulsion",     requires={"srb","nav_accuracy"}},
    {name="Life Support",         area="LifeSupport",       cost=25, duration=8, desc="Crewed missions up to 6 months",              tier=2, unlocks="long_duration",  requires={"avionics_1","heat_shield"}},
    {name="Orbital Rendezvous",   area="Navigation",        cost=18, duration=5, desc="Enables docking & resupply missions",         tier=2, unlocks="rendezvous",     requires={"nav_accuracy"}},
    {name="Cryogenic Upper Stage",area="Cryogenics",        cost=22, duration=7, desc="Higher delta-V for deep space",               tier=2, unlocks="cryo_stage",     requires={"propulsion"}},
    {name="Deep Space Comms",     area="AdvancedSensors",   cost=15, duration=5, desc="Maintains contact beyond Mars",              tier=2, unlocks="deep_comms",     requires={"solar_power"}},
    -- Tier 3
    {name="Nuclear Propulsion",   area="NuclearPropulsion", cost=55, duration=14,desc="Enables crewed Mars missions",               tier=3, unlocks="nuclear_engine", requires={"cryo_stage","long_duration"}},
    {name="Artificial Gravity",   area="ArtificialGravity", cost=40, duration=12,desc="Centrifuge ring; health on long missions",   tier=3, unlocks="art_gravity",    requires={"rendezvous","long_duration"}},
    {name="In-Situ Resources",    area="ISRU",              cost=45, duration=10,desc="Fuel from planetary regolith",               tier=3, unlocks="isru",           requires={"cryo_stage","deep_comms"}},
    {name="Ion Drives",           area="PropulsionTech",    cost=35, duration=9, desc="Ultra-efficient; ideal for probes",          tier=3, unlocks="ion_drive",      requires={"solar_power","deep_comms"}},
    {name="Bio-Regenerative LS",  area="LifeSupport",       cost=50, duration=12,desc="Closed-loop life support; 3yr missions",    tier=3, unlocks="closed_ls",      requires={"art_gravity","isru"}},
}

function buildResearchList(unlocks)
    local list = {}
    for _, r in ipairs(RESEARCH_TREE) do
        -- Check requires satisfied
        local ok = true
        for _, req in ipairs(r.requires) do
            if not (unlocks and unlocks[req]) then ok = false; break end
        end
        if ok then
            local copy = {}
            for k, v in pairs(r) do copy[k] = v end
            copy.progress  = 0
            copy.completed = unlocks and unlocks[copy.unlocks] or false
            table.insert(list, copy)
        end
    end
    return list
end

function rebuildResearch(a)
    -- Rebuild available research based on current unlocks
    a.research = buildResearchList(a.unlocks)
end

function startResearch(a, r)
    if r.progress > 0 or r.completed then return end
    if a.science_pts < r.cost then return end
    a.science_pts = a.science_pts - r.cost
    r.progress = 0.001  -- mark as started
end

function applyResearchUnlock(a, r)
    if not a.unlocks then a.unlocks = {} end
    a.unlocks[r.unlocks] = true
    -- Propagate: rebuild to expose newly unlocked tier-2/3 items
    rebuildResearch(a)
    table.insert(a.completed_research or {}, r.name)
end

function researchSummary(a)
    local done = 0
    local total = #(RESEARCH_TREE)
    for _, r in ipairs(RESEARCH_TREE) do
        if a.unlocks and a.unlocks[r.unlocks] then done = done + 1 end
    end
    return done, total
end
