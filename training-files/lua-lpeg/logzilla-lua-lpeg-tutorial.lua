-- ------------------------------
-- LogZilla - Lua LPEG Examples
-- http://logzilla.net
-- copyright 2022, LogZilla Corp.
-- ------------------------------

local lpeg = require "lpeg"

-- for this, "character" means any letter, number, or punctuation

-- MATCHING A CHARACTER
-- --------------------
-- match any character
local MATCH_ANY_CHARACTER       = lpeg.P(1)

-- match a specific character
local MATCH_CHARACTER_X         = lpeg.P("X")

-- match three of any characters
local MATCH_MORE_THAN_THREE_ANY = lpeg.P(3)

-- match any of these characters
local MATCH_ANY_CHARACTERS = lpeg.S("ABC123")

-- match any of a range of characters
-- in this one, "A" through "Z", or "a" through "z"
-- (caps matter) or "1" through "9"
-- so we're not doing punctuation
local MATCH_CHARACTER_IN_RANGE  = lpeg.R("AZ", "az", "19")


-- MATCH MULTIPLE CHARACTERS
-- -------------------------
-- match the following characters, in order, as given
local MATCH_TEXT_STRING         = lpeg.P("STRING")

-- match any characters, two or more times of any
local MATCH_MORE_THAN_TWO_ANY   = lpeg.P(1)^2

-- match any characters, X or more times of any
local MATCH_MORE_THAN_X_ANY     = lpeg.P(1)^X

-- match the letter "X" two or more times
local MATCH_MORE_THAN_TWO_CHARACTER = lpeg.P("X")^2

-- match any characters, three or less of any
local MATCH_LESS_THAN_THREE_ANY = lpeg.P(1)^-3

-- match any characters, X or fewer times
local MATCH_LESS_THAN_X_ANY     = lpeg.P(1)^-X

-- match less than three copies of the letter "X"
local MATCH_LESS_THAN_THREE_CHARACTERS  =   lpeg.P("X")^-3


-- MATCH ONE OR MORE MATCHES IN A ROW
-- ----------------------------------

-- match the words "name is " followed by three or more of any characters
-- for the name
local MATCH_SEQUENCE_TWOPARTS           =   lpeg.P("name is ") * lpeg.P(1)^3

-- match "first name is " then twenty or fewer characters
-- then ", last name is " followed by thirty or fewer characters
local MATCH_SEQUENCE_FOURPARTS          
    =   lpeg.P("first name is ") * lpeg.P(1)^-20 * lpeg.P(", last name is ") * lpeg.P(1)^-30

-- match either of two words
local MATCH_EITHER_WORD
    =   lpeg.P("first") + lpeg.P("last")

-- match either the words "first name is ", or the words "last name is "
-- followed by twenty characters or less for the actual name
local MATCH EITHER_FIRSTNAME_OR_LASTNAME
    =   (lpeg.P("first") + lpeg.P("last")) + lpeg.P(" name is ") + lpeg.P(1)^-20


-- DON'T MATCH
-- -----------

-- match any character except the letter "X"
local MATCH_ANYTHING_BUT_X              =   lpeg.P(1) - lpeg.P("X")

-- match any letter except "Q"
local MATCH_LETTER_EXCEPT_Q             =   lpeg.R("AZ") - lpeg.P("Q")

-- match any first name or last name except "Henry", 30 letters or fewer
    =   (lpeg.P("first") + lpeg.P("last")) * lpeg.P(" name is" )
    *   (lpeg.R("AZ", "az")^-30 - lpeg.P("Henry"))


-- CAPTURES
-- --------

-- capture a word (letters), 20 characters or fewer
local CAPTURE_A_WORD                    = lpeg.Cg(lpeg.R("AZ" "az")^-20, "capture_name")

-- handle all the captures for a rule
-- in this example, we're going to expect:
--  "first name is ABCDEF, last name is GHIJKL"
-- we're going to get two captures, for first name
-- and last name, which are upper or lower characters
-- only, 30 characters or fewer
-- you have to surround the whole thing with "lpeg.Ct()"
local GET_BOTH_CAPTURES_FOR_RULE
    =   lpeg.Ct(
              lpeg.S("first")
            * lpeg.P(" name is ")
            * lpeg.Cg(lpeg.R("AZ", "az")^-30, "first_name")
            * lpeg.P(" , last name is ")
            * lpeg.Cg(lpeg.R("AZ", "az")^-30, "last_name")
        )


-- SKIPS
-- -----

-- in this example, we'll say the complete log message is
-- "user ABCDEF caused error ERRMSG"
-- note that since the log message starts with "user", and
-- then any name for the user,  we have to skip that before
-- we can capture
local MATCH_SKIP
    =   lpeg.P("user ")
        * (lpeg.P(1) - " ")^1
        * " caused error "
        * lpeg.Cg(lpeg.R("AZ", "az")^-30, "error")



-- DOING THE MATCH IN THE RULE
-- in order to capture anything, you have to match
-- your lpeg expression to the log message
-- we'll assume the expression is "error ABCDEF encountered"
local LOG_MESSAGE = "error CRASH encountered"
local MATCH_EXPRESSION 
    = lpeg.P("error ")
    * lpeg.Ct(
        lpeg.Cg(lpeg.R("AZ", "az")^1, "the_error")
    )
    * lpeg.P(" encountered")

local THE_MATCH = MATCH_EXPRESSION:match(LOG_MESSAGE)

-- now we can use the information we matched
local MY_VARIABLE = THE_MATCH.the_error


-- and set it to a user tag
event.user_tags["Error Message"] = MY_VARIABLE
