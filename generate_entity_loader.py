import os
import io


boilerplate_helpers = """
local function load_mob(_path)
	local mob_info =require(_path)
	
	mob_info.render = glib.renderer.RenderOrder[mob_info.render] or glib.renderer.RenderOrder.DEFAULT
   
	
	gvar.enemie_lookup[mob_info.name] =mob_info
	gvar.enemie_spawn_lookup[mob_info.name]=mob_info.chances
	
	print("Loaded entity  "..mob_info.name)
end


local function load_item(_path)
	local item_info =require(_path)
        
	item_info.render = glib.renderer.RenderOrder[item_info.render] or glib.renderer.RenderOrder.DEFAULT
	
	item_info.slot =  item_info.slot == nil and nil or ( glib.equipment_slots[item_info.slot] or glib.equipment_slots.DEFAULT )
	
	
	gvar.item_lookup[item_info.name] =item_info
	gvar.item_spawn_lookup[item_info.name]=item_info.chances
	
	print("Loaded item  "..item_info.name)
end

"""


fh = open("entity_loader.lua","w")
fh.write(boilerplate_helpers)

for file in os.listdir("../Rogue/generated/enemies"):
	fh.write("load_mob(\"generated.enemies."+file.replace(".lua","")+"\")\n")


fh.write("\n--loading items\n")
for file in os.listdir("../Rogue/generated/items"):
	fh.write("load_item(\"generated.items."+file.replace(".lua","")+"\")\n")

fh.close()
