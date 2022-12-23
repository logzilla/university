-- ------------------------------
-- LogZilla - Lua Rule Example
-- http://logzilla.net
-- copyright 2022, LogZilla Corp.
-- ------------------------------

-- rule section 1:  lua "requires"
-- (lua "requires" would go here, in this rule none are needed)


-- rule section 2:  lpeg/regular expressions
local INFOBLOX_DNSQUERY_REGEXP = rex.new(
    "infoblox-responses: \\S*\\s\\S*\\s"
    .. "client (\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})#"
    .. "(\\d+): ([^:]+: [^:]+:) (\\S*)\\s(\\S*)\\s(\\S*) response: (\\S*) (.*)"
)


-- rule section 3:  "process" function
function process(event)
    if event.program == "named" then
        local match = { rex.match(event.message, INFOBLOX_DNSQUERY_REGEXP) }
        if match and match[1] and match[1] ~= "" then
            event.program = "Infoblox"
            event.user_tags["SrcIP"] = match[1]
            event.user_tags["Query"] = match[4]
            event.user_tags["Query Type"] = match[6]
            event.user_tags["Response"] = match[7]
            event.message = 
                "client "
                .. match[1] .. "#" .. match[2] .. ": "
                .. match[3] .. " "
                .. match[4] .. " "
                .. match[5] .. " "
                .. match[6] .. " "
                .. "response: "
                .. match[7] .. " "
                .. match[8]
        end
    end
end


-- rule section 4:  high-cardinality ("HC") user tags
HC_TAGS={
    "SrcIP",
    "Query"
}
