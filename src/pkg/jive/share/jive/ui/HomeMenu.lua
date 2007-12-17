
local assert = assert

local oo            = require("loop.base")
local table         = require("jive.utils.table")

local SimpleMenu    = require("jive.ui.SimpleMenu")
local Window        = require("jive.ui.Window")

local log           = require("jive.utils.log").logger("ui")


-- our class
module(..., oo.class)


-- create a new menu
function __init(self, name, style, titleStyle)
	local obj = oo.rawnew(self, {
		window = Window(style or "window", name, titleStyle),
		menuTable = {},
		nodeTable = {},
	})

	local menu = SimpleMenu("menu")
	menu:setComparator(SimpleMenu.itemComparatorWeightAlpha)

	-- home menu is not closeable
	menu:setCloseable(false)

	obj.window:addWidget(menu)
	obj.nodeTable['home'] = {
		menu = menu, 
		items = {}
	}

	return obj
end


function _changeNode(self, id, node)
	-- looks at the node and decides whether it needs to be removed
	-- from a different node before adding
	if self.menuTable[id] and self.menuTable[id].node != node then 
		-- remove menuitem from previous node
		table.delete(self.nodeTable[node].items, self.menuTable[id])
		-- change menuitem's node
		self.menuTable[id].node = node
		-- add item to that node
		addNode(self.menuTable[id])
	end
end


function addNode(self, item)
	assert(item.id)
	assert(item.node)

	log:debug("JiveMain.addNode: Adding a non-root node, ", item.id)

	if not item.weight then 
		item.weight = 5
	end

	-- remove node from previous node (if changed)
	if self.menuTable[item.id] then
		local newNode    = item.node
		local prevNode   = self.menuTable[id].node
		if newNode != prevNode then
			_changeNode(item.id, newNode)
		end
	end

	-- new/update node

	local window
	if item.window and item.window.titleStyle then
		window = Window("window", item.text, item.window.titleStyle .. "title")
	elseif item.titleStyle then
		window = Window("window", item.text, item.titleStyle .. "title")
	else
		window = Window("window", item.text)
	end

	local menu = SimpleMenu("menu", item)
	menu:setComparator(SimpleMenu.itemComparatorWeightAlpha)

	window:addWidget(menu)

	self.nodeTable[item.id] = { menu = menu, 
				items = {} }

	if not item.callback then
		item.callback = function () 
       	                 window:show()
		end
	end

	if not item.sound then
		sound = "WINDOWSHOW"
	end

	-- now add the item to the menu
	self:addItem(item)
end


-- add an item to a menu. the menu is ordered by weight, then item name
function addItem(self, item)
	assert(item.id)
	assert(item.node)

	if not item.weight then 
		item.weight = 5
	end

	if not self.menuTable[item.id] then
		log:debug("JiveMain.addItem: Adding ", item.text, " to ", item.node)
		self.menuTable[item.id] = item

	else
		log:debug("THIS ID ALREADY EXISTS, removing existing item")
--		table.delete(self.nodeTable[item.node].items, self.menuTable[item.id])
		self.menuTable[item.id] = item
	end

	table.insert(self.nodeTable[item.node].items, item)
	self.nodeTable[item.node].menu:addItem(item)
end


-- remove an item from a menu by its index
function removeItem(self, item)
	self.menu:removeItem(item)
end


-- remove an item from a menu by its id
function removeItemById(self, id)
	self.menu:removeItemById(id)
end


-- lock an item in the menu
function lockItem(self, item, ...)
	if self.nodeTable[item.node] then
		self.nodeTable[item.node].menu:lock(...)
	end
end


-- unlock an item in the menu
function unlockItem(self, item)
	if self.nodeTable[item.node] then
		self.nodeTable[item.node].menu:unlock()
	end
end


-- iterator over items in menu
function iterator(self)
	return self.menu:iterator()
end


--[[

=head1 LICENSE

Copyright 2007 Logitech. All Rights Reserved.

This file is subject to the Logitech Public Source License Version 1.0. Please see the LICENCE file for details.

=cut
--]]
