local S = core.get_translator("no_melterns_no_tools")

no_melterns_no_tools = {}
local nmnt = no_melterns_no_tools

---------------------------------------------------------------- Sand casting
nmnt.sand_casting_recipies = {}

if i3 and i3.register_craft_type then
    i3.register_craft_type("no_melterns_no_tools:sand_casting", {
        description = S("Sand casting"),
        icon = "default_steel_ingot.png",
    })
end

function nmnt.register_sand_cast(item, ingot)
    nmnt.sand_casting_recipies[item] = ingot
    if i3 and i3.register_craft then
        i3.register_craft {
            type = "no_melterns_no_tools:sand_casting",
            result = ingot,
            items = { item }
        }
    end
end

core.register_node("no_melterns_no_tools:sand_cast", {
    description = S("Sand Cast"),
    groups = { crumbly = 3, sand = 1 },
    drawtype = "mesh",
    mesh = "no_melterns_no_tools_sand_cast.obj",
    tiles = { "default_sand.png" },
})

core.register_node("no_melterns_no_tools:sand_cast_full", {
    groups = { crumbly = 3, sand = 1, not_in_creative_inventory = 1 },
    drawtype = "mesh",
    mesh = "no_melterns_no_tools_sand_cast_full.obj",
    tiles = { "default_sand.png", "default_sand.png", "default_sand.png", "default_sand.png", "default_sand.png", "default_silver_sandstone.png" },
    drop = "no_melterns_no_tools:sand_cast",
    on_destruct = function(pos)
        local meta = core.get_meta(pos)
        core.add_item({ x = pos.x, y = pos.y + 1, z = pos.z }, meta:get_string("ingot"))
    end,
})

core.register_craft({
    type = "shapeless",
    output = "no_melterns_no_tools:sand_cast",
    recipe = { "group:sand" }
})

core.register_abm({
    label = S("Sand casting"),
    nodenames = { "no_melterns_no_tools:sand_cast" },
    neighbors = { "default:lava_source", "default:lava_flowing" },
    interval = 10.0,
    chance = 1,
    min_y = -32768,
    max_y = 32767,
    catch_up = true,
    action = function(pos, _, _, _)
        local pos_up = { x = pos.x, y = pos.y + 1, z = pos.z }
        for _, obj in ipairs(core.get_objects_inside_radius(pos_up, 1)) do
            local luaentity = obj:get_luaentity()
            if luaentity and luaentity.name == "__builtin:item" then
                local item = ItemStack(core.deserialize(luaentity:get_staticdata()).itemstring)
                if nmnt.sand_casting_recipies[item:get_name()] then
                    if item:get_count() > 1 then
                        item:set_count(item:get_count() - 1)
                        luaentity:set_item(item)
                    else
                        obj:remove()
                    end
                    core.set_node(pos, { name = "no_melterns_no_tools:sand_cast_full", param1 = 0, param2 = 0 })
                    local meta = core.get_meta(pos)
                    meta:set_string("ingot", nmnt.sand_casting_recipies[item:get_name()])
                    return
                end
            end
        end
    end,
})

if awards and awards.register_award then
    local goals_api = awards.registered_goals ~= nil

    -- First ingot
    local description = "Make your first ingot using sand casting"
    local def = {
        title = S("First ingot"),
        description = S(goals_api
            and
            description
            or description ..
            " (Craft a sand cast and put it near lava, drop item to melt on it, wait for it to smelt and break the cast)"),
        icon = "default_steel_ingot.png",
        goals = {
            {
                description = S("Craft the sand cast"),
                trigger = {
                    type = "craft",
                    item = "no_melterns_no_tools:sand_cast",
                    target = 1,
                },
            },
            {
                description = S("Put the cast down near lava"),
                trigger = {
                    type = "place",
                    node = "no_melterns_no_tools:sand_cast",
                    target = 1,
                },
            },
            {
                description = S("Dig the sand cast with an ingot"),
                trigger = {
                    type = "dig",
                    node = "no_melterns_no_tools:sand_cast_full",
                    target = 1,
                },
            },
        },
    }
    if not goals_api then
        def.target = def.goals[#def.goals]
    end
    awards.register_award("no_melterns_no_tools:first_ingot", def)

    -- Toolsmith
    awards.register_award("no_melterns_no_tools:toolsmith", {
        title = S("Toolsmith"),
        description = S("Craft a pickaxe using tool station"),
        icon = "default_tool_steelpick.png",
        trigger = {
            type = "tinkering:tool_creation",
            target = 1,
        },
    })
end

---------------------------------------------------------------- Remove default tool crafts (Leaving the hoe)
function nmnt.remove_material(mod, material, tools, ingot)
    if tools then
        core.clear_craft({ output = mod .. ":axe_" .. material })
        core.clear_craft({ output = mod .. ":pick_" .. material })
        core.clear_craft({ output = mod .. ":shovel_" .. material })
        core.clear_craft({ output = mod .. ":sword_" .. material })
    end
    if ingot then
        local ingot_name = mod .. ":" .. material .. "_ingot"
        local recipes = core.get_all_craft_recipes(ingot_name)
        if recipes then
            for _, recipe in ipairs(recipes) do
                if recipe.method == "cooking" then
                    core.clear_craft({ type = "cooking", recipe = recipe.items[1] })
                    nmnt.register_sand_cast(recipe.items[1], ingot_name)
                end
            end
        end
    end
end

nmnt.remove_material("default", "wood", true, false)
nmnt.remove_material("default", "stone", true, false)
nmnt.remove_material("default", "steel", true, true)
nmnt.remove_material("default", "bronze", true, false)
nmnt.remove_material("default", "copper", false, true)
nmnt.remove_material("default", "gold", false, true)
nmnt.remove_material("default", "tin", false, true)
nmnt.remove_material("default", "mese", true, false)
nmnt.remove_material("default", "diamond", true, false)
if core.get_modpath("ethereal") then
    nmnt.remove_material("ethereal", "crystal", true, false)
end

if core.settings:get_bool("no_melterns_no_tools_no_wood") then
    ---------------------------------------------------------------- Missing craft tweaks
    core.register_craft({
        type = "shapeless",
        output = "default:stick",
        recipe = { "group:leaves" }
    })

    ---------------------------------------------------------------- Sharp stick
    core.register_tool("no_melterns_no_tools:sharp_stick", {
        description = S("Sharp Stick"),
        inventory_image = "no_melterns_no_tools_sharp_stick.png",
        tool_capabilities = {
            full_punch_interval = 1.2,
            max_drop_level = 0,
            groupcaps = {
                cracky = { times = { [3] = 3.00 }, uses = 1, maxlevel = 1 },
                choppy = { times = { [2] = 6.00, [3] = 3.00 }, uses = 1, maxlevel = 1 },
            },
            damage_groups = { fleshy = 2 },
        },
        sound = { breaks = "default_tool_breaks" },
        groups = { pickaxe = 1, flammable = 2 }
    })

    core.register_craft({
        type = "shapeless",
        output = "no_melterns_no_tools:sharp_stick",
        recipe = { "default:stick" }
    })

    minetest.register_craft({
        type = "fuel",
        recipe = "no_melterns_no_tools:sharp_stick",
        burntime = 1,
    })

    ---------------------------------------------------------------- Primitive tool
    core.register_tool("no_melterns_no_tools:primitive_tool", {
        description = S("Primitive Tool"),
        inventory_image = "no_melterns_no_tools_primitive_tool.png",
        tool_capabilities = {
            full_punch_interval = 1.2,
            max_drop_level = 0,
            groupcaps = {
                cracky = { times = { [3] = 2.00 }, uses = 3, maxlevel = 1 },
                choppy = { times = { [2] = 4.00, [3] = 2.00 }, uses = 3, maxlevel = 1 },
            },
            damage_groups = { fleshy = 3 },
        },
        sound = { breaks = "default_tool_breaks" },
        groups = { pickaxe = 1, axe = 1, flammable = 2 }
    })

    core.register_craft({
        output = "no_melterns_no_tools:primitive_tool",
        recipe = {
            { "group:stone" },
            { "group:stick" }
        }
    })

    ---------------------------------------------------------------- Make planks only craftable with an axe
    local axes = {}
    for name, def in pairs(core.registered_items) do
        if def.groups.axe then
            table.insert(axes, name)
        end
    end

    local register_craft_old = core.register_craft
    core.register_craft = function(recipe)
        if recipe.type == "shapeless" then
            local item = ItemStack(recipe.output):get_name()
            if core.registered_items[item] and core.registered_items[item].groups.wood then
                if #recipe.recipe == 1 and core.registered_items[recipe.recipe[1]] and core.registered_items[recipe.recipe[1]].groups.tree then
                    for _, axe in ipairs(axes) do
                        local new_recipe = table.copy(recipe)
                        table.insert(new_recipe.recipe, axe)
                        new_recipe.replacements = new_recipe.replacements or {}
                        table.insert(new_recipe.replacements, { axe, axe })
                        register_craft_old(new_recipe)
                    end
                    return
                end
            end
        end
        register_craft_old(recipe)
    end

    for name, def in pairs(core.registered_items) do
        if def.groups.tree then
            local wood = name:gsub("tree", "wood"):gsub("trunk", "wood")
            if core.registered_items[wood] and core.registered_items[wood].groups.wood then
                core.clear_craft({ recipe = { { name } } })
                core.register_craft({
                    type = "shapeless",
                    output = wood .. " 4",
                    recipe = { name },
                })
            end
        end
    end

    ---------------------------------------------------------------- Awards
    if awards and awards.register_award then
        local goals_api = awards.registered_goals ~= nil

        -- Stone age
        local trigger = {
            type = "dig",
            node = "group:stone",
            target = 1,
        }
        awards.register_award("no_melterns_no_tools:pointy_stick", {
            title = S("Stone age"),
            description = S("Craft a sharp stick and mine some stone"),
            icon = "no_melterns_no_tools_sharp_stick.png",
            goals = goals_api and {
                {
                    description = S("Craft the sharp stick"),
                    trigger = {
                        type = "craft",
                        item = "no_melterns_no_tools:sharp_stick",
                        target = 1,
                    },
                },
                {
                    description = S("Mine some stone"),
                    trigger = trigger
                },
            },
            trigger = not goals_api and trigger,
        })

        -- Swing of an axe
        trigger = {
            type = "craft",
            item = "group:wood",
            target = 1,
        }
        awards.register_award("no_melterns_no_tools:axe_swing", {
            title = S("Swing of an axe"),
            description = S("Craft a primitive tool and make wood using it"),
            icon = "no_melterns_no_tools_primitive_tool.png",
            goals = goals_api and {
                {
                    description = S("Craft the primitive tool"),
                    trigger = {
                        type = "craft",
                        item = "no_melterns_no_tools:primitive_tool",
                        target = 1,
                    },
                },
                {
                    description = S("Craft some wood"),
                    trigger = trigger,
                },
            },
            trigger = not goals_api and trigger,
        })
    end
end
