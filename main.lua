local tester = require("tester")


--generate entity loader file
os.execute("python3 generate_entity_loader.py")

debuger={on=function()end,off=function()end}
--adjust the path to contain the main rogue folder
package.path=package.path..";".."../Rogue/?.lua"
print(package.path)


debuger = require("mobdebug")
debuger.start()



class_base = require("helper.classic"):extend()
g=require("globals")


local g=require("game")

--load up defaults and entities
g.load()
g.load_from_save("test_save.json")


debuger.on()
glib = g.libs
gvar = g.vars

local add = tester.add_test


require("entity_loader")
debuger.on()


-------------------------------------------
-- HELPERS

local function count(t)
	local c =0
	for k,_ in pairs(t) do
		c=c+1
	end
	return c
end

function sim_key(key)
 g.keyHandle(key,0,0,true)	
 --simulate two updates, one for the player and one for the possible enemy turn 
 g.update()
 g.update()  
 g.keyHandle(key,0,0,false) 
 gvar.key_timer=gvar.key_timer-0.2 
 
end


function dlog(msg)
  tester.log("DEBUG","",msg)	
end



function get_default_mob(name,pos_x,pos_y)
	  dlog("num enemies: "..count(gvar.enemie_lookup))
	  for k,v in pairs(gvar.enemie_lookup) do
		dlog(k)
	  end
	  local mob = gvar.enemie_lookup[name]
      local stats_= glib.Fighter(mob.hp,mob.def,mob.power,mob.exp)
      local behaviour_ =glib.ai[mob.ai]()
      
      return glib.Entity(pos_x,pos_y,0,mob.color,mob.name,mob.blocking,stats_,behaviour_,mob.render)
end


function get_default_item(name,pos_x,pos_y)
	local item_tmp = gvar.item_lookup[name]
	local item_comp = nil
	local equippment_component = nil
	local message_component = nil
	
	if item_tmp.type == "item" then
		if item_tmp.message then
		   message_component =glib.msg_renderer.Message(item_tmp.message.text,gvar.constants.colors[item_tmp.message.color]) 
		end
		
		item_comp = glib.inventory.Item(glib.item_functions[item_tmp["function"]],item_tmp.is_ranged,message_component,item_tmp.arguments)
	else
		equippment_component =glib.Equipable(item_tmp.slot,item_tmp.health,item_tmp.def,item_tmp.power)
	end
	
	
	local collectable = glib.Entity(pos_x,pos_y,0,item_tmp.color,item_tmp.name,item_tmp.blocking,nil,nil,item_tmp.render,item_comp,nil,nil,nil,nil,equippment_component)
	  
	return collectable
end





---------------------------------------------------------------------------------
--save load tests
--TODO: Add cases for each version of the file
            
add(function()
                     local result = glib.data_loader.load_game("test_save.json")
                     if tester.type_equals(result,{}) == true then
                        tester.equals(result[1],true)
                     end
                end,{name="successfull load"})
            
add(function()
                     local result = glib.data_loader.load_game("some_file.json")
                     if tester.type_equals(result,{}) == true then
                        tester.equals(result[1],false)
                     end
                end,{name="failed load"})
 

add(function()
                    g.load_from_save("test_save.json")
                    tester.equals(count(gvar.entities),8)
                end
            ,{name="Entities loaded right"})


--------------------------------------------------------------------
--check key handling


--movement
add(
	function()
		--dissable the main menue flag .... TODO change to be a game state or adjust on load to set to false
		gvar.show_main_menue=false
		
		g.load_from_save("test_save.json")
		local player_x = gvar.player.x
		local player_y = gvar.player.y
		
		tester.log("DEBUG","","Moving left...")
		sim_key("left")
		tester.equals(player_x -1,gvar.player.x)
		
		tester.log("DEBUG","","Moving right...")
		sim_key("right")
		tester.equals(player_x,gvar.player.x)
		
		tester.log("DEBUG","","Moving up...")
		sim_key("up")
		tester.equals(player_y-1,gvar.player.y)

		tester.log("DEBUG","","Moving down...")
		sim_key("down")
		tester.equals(player_y,gvar.player.y)

	end,
	{name="Movements"}
	)


add(function() 
		g.load_from_save("test_save.json")
		gvar.entities ={}
		local player_x = gvar.player.x
		local player_y = gvar.player.y
		
		
		--wall collosion , we know there is a wall in one step so move twice and it will move only once
		sim_key("left")
		sim_key("left")
		dlog("wall collision")
		tester.equals(player_x-1,gvar.player.x)
		
		sim_key("right")
		
		
		debuger.on()
		
		--blocking entity collision
		dlog("entity collisison")
		
		
		player_x = gvar.player.x
		player_y = gvar.player.y
		
		table.insert(gvar.entities, get_default_mob("Dummy",player_x+1,player_y))
		sim_key("right")
		
		--should have the same place since enemy is blocking
		tester.equals(player_x,gvar.player.x)
		
		debuger.on()
		
		--nonblocking entity
		gvar.entities={}
		table.insert(gvar.entities,get_default_item("Small health potion",player_x+1,player_y))
		sim_key("right")
		tester.equals(player_x+1,gvar.player.x)
		
	end,
	{name="Collisions"}
	)

--------------------------------------------------------
--start the test loop
while true do
  tester.run_tests()
end
