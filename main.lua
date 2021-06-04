local tester = require("tester")

debuger={on=function()end,off=function()end}
--adjust the path to contain the main rogue folder
package.path=package.path..";".."../Rogue/?.lua"


class_base = require("helper.classic"):extend()
g=require("globals")
glib = g.libs
gvar = g.vars

local g=require("game")

--load up defaults and entities
g.load()
g.load_from_save("test_save.json")


---------------------------------------------------------------------------------
--save load tests
--TODO: Add cases for each version of the file
            
tester.add_test(function()
                     local result = glib.data_loader.load_game("test_save.json")
                     if tester.type_equals(result,{}) == true then
                        tester.equals(result[1],true)
                     end
                end,{name="successfull load"})
            
tester.add_test(function()
                     local result = glib.data_loader.load_game("some_file.json")
                     if tester.type_equals(result,{}) == true then
                        tester.equals(result[1],false)
                     end
                end,{name="failed load"})


tester.add_test(function()
                    g.load_from_save("test_save.json")
                    tester.equals(#gvar.entities,8)
                end
            ,{name="Entities loaded right"})



----------------------------------------------------------------------------------
-- entity / item loadup check
while true do
tester.run_tests()
end