-- ------------------------------
-- LogZilla - GeoIP Rule Example
-- http://logzilla.net
-- copyright 2022, LogZilla Corp.
-- ------------------------------

-- load lua libraries
local lpeg = require "lpeg"
local core = require "lpeg_patterns.core"
local helpers = require "helpers"
local geoip = helpers.get_GeoIP()

-- regular expression to get the IP address from the log message
DHCPD_RE = rex.new("DHCPACK on (\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})")

-- the standard 'process' function that does all the work for
-- each incoming log message
function process(event)

    -- check to see if this log message is in fact a DHCP log message.
    -- if it's not, then we don't want to continue with this rule
    -- so just return
    if event.program ~= "dhcpd" then
        return
    end

    -- check if our DHCPD_RE regular expression matches the event message.
    -- if it does match, put the captured value in a lua variable called src_ip
    local src_ip = rex.match(event.message, DHCPD_RE)

    -- check to see if it matched, if not then we don't want to run the
    -- rest of this rule, so just return
    if not src_ip then
        return
    end

    -- if we made it this far, the our regular expression matched and
    -- the ip address is in the variable 'src_ip'

    -- method 1:
    -- for this method, you _must_ have a user tag already assigned,
    -- with the IP address in it
    -- so we'll make a user tag 'SrcIP' and set it to the value of
    -- 'src_ip', which you'll remember from above is the IP address
    -- that we got using the regular expression
    event.user_tags["SrcIP"] = src_ip
    
    -- now that we have made the 'SrcIP' user tag, we can call the
    -- function in the LogZilla library that reads from that user tag
    geoip:add_geo_tags(event, "SrcIP")

    -- now what that function did, is that it made three totally new
    -- user tags, using the same name as the user tag that we gave
    -- to the function when we called it.
    -- it takes the user tag 'SrcIP' and then appends the location
    -- specificity to the end of the user tag name, and makes
    -- user tags, three times.

    -- this next section just checks to see if some of the location 
    -- information for that IP address could not be determined.  if
    -- it cannot be determined then put the word "Unknown" in the
    -- user tag
    if event.user_tags["SrcIP City"] == nil then
        event.user_tags["SrcIP City"] = "Unknown"
    end
    if event.user_tags["SrcIP State"] == nil then
        event.user_tags["SrcIP State"] = "Unknown"
    end
    if event.user_tags["SrcIP Country"] == nil then
        event.user_tags["SrcIP Country"] = "Unknown"
    end

    -- method 2:
    -- this is the library function call from the LogZilla lua
    -- library. 'geoip.get_values' is the name of the lua library
    -- function that we are calling
    -- we tell it to do that on the variable 'src_ip' and then we
    -- put the result in variable 'geo_data'
    local geo_data = geoip:get_values(src_ip)

    -- ok now the 'geo_data' variable contains all three portions of
    -- the IP address location: city, state, and country
    -- this is how you access those pieces to put them in user tags
    event.user_tags["SrcIP City 2"] = geo_data["City"] or "Unknown"
    event.user_tags["SrcIP State 2"] = geo_data["State"] or "Unknown"
    event.user_tags["SrcIP Country 2"] = geo_data["Country"] or "Unknown"
    -- the 'or "Unknown"' just means that if for whatever reason this
    -- location information could be looked up, then put "Unknown" into
    -- the user tag

    -- and thats it!
    -- we made three new user tags using method one, and three new
    -- user tags using method 2.
    -- those user tags are ready for widgets, for searching and
    -- filtering, and to put in emails
end


-- set high-cardinality tags.
-- we expect 50 or more values for city, and perhaps state
-- country is less likely to have 50 so we'll leave it
HC_Tags = {
    "SrcIP City", 
    "SrcIP State",
    "SrcIP City 2", 
    "SrcIP State 2",
}

