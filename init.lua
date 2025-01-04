local function remove_material(mod, material, tools, ingot)
    if tools then
        core.clear_craft({ output = mod..":axe_"..material })
        core.clear_craft({ output = mod..":pick_"..material })
        core.clear_craft({ output = mod..":shovel_"..material })
        core.clear_craft({ output = mod..":sword_"..material })
        core.clear_craft({ output = mod..":hoe_"..material })
    end
    if ingot then
        core.clear_craft({ output = mod..":"..material.."_ingot" })
    end
end

remove_material("default", "wood", true, false)
remove_material("default", "stone", true, false)
remove_material("default", "steel", true, true)
remove_material("default", "bronze", true, true)
remove_material("default", "mese", true, false)
remove_material("default", "diamond", true, false)
remove_material("etherial", "crystal", true, false)

minetest.register_craft({
	output = 'metal_melter:heat_exchanger',
	recipe = {
		{'default:iron_lump',         'default:iron_lump',         'default:iron_lump'},
		{'metal_melter:heated_brick', 'metal_melter:heated_brick', 'metal_melter:heated_brick'},
	}
})
