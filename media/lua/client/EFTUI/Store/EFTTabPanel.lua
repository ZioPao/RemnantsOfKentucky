
require "ISUI/ISTabPanel"

EFTTabPanel = ISTabPanel:derive("ISTabPanel")

function EFTTabPanel:addView(name, view)
	local viewObject = {}
	viewObject.name = name
	viewObject.view = view
	viewObject.tabWidth = getTextManager():MeasureStringX(UIFont.Small, name) + self.tabPadX
	viewObject.fade = UITransition.new()
	table.insert(self.viewList, viewObject)
	-- the view have to be under our tab
	view:setY(self.tabHeight)
--	view:initialise()
	self:addChild(view)
	view.parent = self
	-- the 1st view will be default visible
	if #self.viewList == 1 then
		view:setVisible(true)
		self.activeView = viewObject
		self.maxLength = viewObject.tabWidth
	else
		view:setVisible(false)
		if viewObject.tabWidth > self.maxLength then
			self.maxLength = viewObject.tabWidth
		end
	end
end