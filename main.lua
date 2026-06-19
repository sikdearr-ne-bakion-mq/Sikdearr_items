local LP = game:GetService("Players").LocalPlayer
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local Luna = {}
Luna.__index = Luna

local function tw(o,p,t) TS:Create(o,TweenInfo.new(t or 0.2,Enum.EasingStyle.Quad),p):Play() end

local function corner(o,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 6) c.Parent=o return c end

local function makeDrag(frame,handle)
	local dragging,dragInput,mousePos,framePos
	handle.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			dragging=true mousePos=i.Position framePos=frame.Position
			i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
		end
	end)
	handle.InputChanged:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then dragInput=i end
	end)
	UIS.InputChanged:Connect(function(i)
		if i==dragInput and dragging then
			local delta=i.Position-mousePos
			frame.Position=UDim2.new(framePos.X.Scale,framePos.X.Offset+delta.X,framePos.Y.Scale,framePos.Y.Offset+delta.Y)
		end
	end)
end

function Luna.new(title)
	local gui=Instance.new("ScreenGui")
	gui.Name="LunaUI"
	gui.ResetOnSpawn=false
	gui.Parent=LP:WaitForChild("PlayerGui")

	local main=Instance.new("Frame")
	main.Size=UDim2.new(0,520,0,360)
	main.Position=UDim2.new(0.5,-260,0.5,-180)
	main.BackgroundColor3=Color3.fromRGB(24,24,28)
	main.Parent=gui
	corner(main,10)

	local top=Instance.new("Frame")
	top.Size=UDim2.new(1,0,0,36)
	top.BackgroundColor3=Color3.fromRGB(18,18,22)
	top.Parent=main
	corner(top,10)

	local titleLbl=Instance.new("TextLabel")
	titleLbl.Size=UDim2.new(1,-16,1,0)
	titleLbl.Position=UDim2.new(0,12,0,0)
	titleLbl.BackgroundTransparency=1
	titleLbl.Text=title or "Luna UI"
	titleLbl.TextColor3=Color3.fromRGB(235,235,240)
	titleLbl.Font=Enum.Font.GothamBold
	titleLbl.TextSize=15
	titleLbl.TextXAlignment=Enum.TextXAlignment.Left
	titleLbl.Parent=top

	makeDrag(main,top)

	local tabBar=Instance.new("Frame")
	tabBar.Size=UDim2.new(0,130,1,-46)
	tabBar.Position=UDim2.new(0,0,0,46)
	tabBar.BackgroundColor3=Color3.fromRGB(18,18,22)
	tabBar.Parent=main
	corner(tabBar,8)

	local tabList=Instance.new("UIListLayout")
	tabList.Padding=UDim.new(0,4)
	tabList.Parent=tabBar

	local pad=Instance.new("UIPadding")
	pad.PaddingTop=UDim.new(0,8)
	pad.PaddingLeft=UDim.new(0,6)
	pad.PaddingRight=UDim.new(0,6)
	pad.Parent=tabBar

	local container=Instance.new("Frame")
	container.Size=UDim2.new(1,-142,1,-46)
	container.Position=UDim2.new(0,138,0,46)
	container.BackgroundTransparency=1
	container.Parent=main

	local self=setmetatable({},Luna)
	self.Gui=gui
	self.Main=main
	self.TabBar=tabBar
	self.Container=container
	self.Tabs={}
	self.Active=nil
	return self
end

function Luna:Tab(name)
	local btn=Instance.new("TextButton")
	btn.Size=UDim2.new(1,0,0,30)
	btn.BackgroundColor3=Color3.fromRGB(28,28,34)
	btn.Text=name
	btn.TextColor3=Color3.fromRGB(210,210,215)
	btn.Font=Enum.Font.Gotham
	btn.TextSize=13
	btn.AutoButtonColor=false
	btn.Parent=self.TabBar
	corner(btn,6)

	local page=Instance.new("ScrollingFrame")
	page.Size=UDim2.new(1,0,1,0)
	page.BackgroundTransparency=1
	page.ScrollBarThickness=3
	page.Visible=false
	page.CanvasSize=UDim2.new(0,0,0,0)
	page.AutomaticCanvasSize=Enum.AutomaticSize.Y
	page.Parent=self.Container

	local list=Instance.new("UIListLayout")
	list.Padding=UDim.new(0,8)
	list.Parent=page

	local pad=Instance.new("UIPadding")
	pad.PaddingTop=UDim.new(0,6)
	pad.PaddingLeft=UDim.new(0,6)
	pad.PaddingRight=UDim.new(0,6)
	pad.Parent=page

	local tabObj={Btn=btn,Page=page}
	table.insert(self.Tabs,tabObj)

	btn.MouseButton1Click:Connect(function()
		for _,t in pairs(self.Tabs) do
			t.Page.Visible=false
			tw(t.Btn,{BackgroundColor3=Color3.fromRGB(28,28,34)})
		end
		page.Visible=true
		tw(btn,{BackgroundColor3=Color3.fromRGB(70,70,200)})
		self.Active=tabObj
	end)

	if not self.Active then
		page.Visible=true
		btn.BackgroundColor3=Color3.fromRGB(70,70,200)
		self.Active=tabObj
	end

	local api={}

	function api:Button(text,callback)
		local b=Instance.new("TextButton")
		b.Size=UDim2.new(1,0,0,32)
		b.BackgroundColor3=Color3.fromRGB(34,34,40)
		b.Text=text
		b.TextColor3=Color3.fromRGB(230,230,235)
		b.Font=Enum.Font.Gotham
		b.TextSize=13
		b.AutoButtonColor=false
		b.Parent=page
		corner(b,6)
		b.MouseButton1Click:Connect(function() if callback then callback() end end)
		b.MouseEnter:Connect(function() tw(b,{BackgroundColor3=Color3.fromRGB(44,44,52)},0.1) end)
		b.MouseLeave:Connect(function() tw(b,{BackgroundColor3=Color3.fromRGB(34,34,40)},0.1) end)
		return b
	end

	function api:Toggle(text,default,callback)
		local state=default or false
		local f=Instance.new("Frame")
		f.Size=UDim2.new(1,0,0,32)
		f.BackgroundColor3=Color3.fromRGB(34,34,40)
		f.Parent=page
		corner(f,6)

		local lbl=Instance.new("TextLabel")
		lbl.Size=UDim2.new(1,-50,1,0)
		lbl.Position=UDim2.new(0,10,0,0)
		lbl.BackgroundTransparency=1
		lbl.Text=text
		lbl.TextColor3=Color3.fromRGB(230,230,235)
		lbl.Font=Enum.Font.Gotham
		lbl.TextSize=13
		lbl.TextXAlignment=Enum.TextXAlignment.Left
		lbl.Parent=f

		local sw=Instance.new("Frame")
		sw.Size=UDim2.new(0,38,0,18)
		sw.Position=UDim2.new(1,-46,0.5,-9)
		sw.BackgroundColor3=state and Color3.fromRGB(70,70,200) or Color3.fromRGB(60,60,66)
		sw.Parent=f
		corner(sw,9)

		local dot=Instance.new("Frame")
		dot.Size=UDim2.new(0,14,0,14)
		dot.Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
		dot.BackgroundColor3=Color3.fromRGB(240,240,245)
		dot.Parent=sw
		corner(dot,7)

		local click=Instance.new("TextButton")
		click.Size=UDim2.new(1,0,1,0)
		click.BackgroundTransparency=1
		click.Text=""
		click.Parent=f

		click.MouseButton1Click:Connect(function()
			state=not state
			tw(sw,{BackgroundColor3=state and Color3.fromRGB(70,70,200) or Color3.fromRGB(60,60,66)},0.15)
			tw(dot,{Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)},0.15)
			if callback then callback(state) end
		end)
		return f
	end

	function api:Slider(text,min,max,default,callback)
		min=min or 0 max=max or 100
		local val=default or min
		local f=Instance.new("Frame")
		f.Size=UDim2.new(1,0,0,46)
		f.BackgroundColor3=Color3.fromRGB(34,34,40)
		f.Parent=page
		corner(f,6)

		local lbl=Instance.new("TextLabel")
		lbl.Size=UDim2.new(1,-50,0,20)
		lbl.Position=UDim2.new(0,10,0,4)
		lbl.BackgroundTransparency=1
		lbl.Text=text
		lbl.TextColor3=Color3.fromRGB(230,230,235)
		lbl.Font=Enum.Font.Gotham
		lbl.TextSize=13
		lbl.TextXAlignment=Enum.TextXAlignment.Left
		lbl.Parent=f

		local valLbl=Instance.new("TextLabel")
		valLbl.Size=UDim2.new(0,40,0,20)
		valLbl.Position=UDim2.new(1,-46,0,4)
		valLbl.BackgroundTransparency=1
		valLbl.Text=tostring(val)
		valLbl.TextColor3=Color3.fromRGB(200,200,210)
		valLbl.Font=Enum.Font.Gotham
		valLbl.TextSize=13
		valLbl.TextXAlignment=Enum.TextXAlignment.Right
		valLbl.Parent=f

		local bar=Instance.new("Frame")
		bar.Size=UDim2.new(1,-20,0,6)
		bar.Position=UDim2.new(0,10,1,-14)
		bar.BackgroundColor3=Color3.fromRGB(50,50,58)
		bar.Parent=f
		corner(bar,3)

		local fill=Instance.new("Frame")
		fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
		fill.BackgroundColor3=Color3.fromRGB(70,70,200)
		fill.Parent=bar
		corner(fill,3)

		local drag=false
		bar.InputBegan:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true end
		end)
		UIS.InputEnded:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
		end)
		UIS.InputChanged:Connect(function(i)
			if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
				local rel=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
				val=math.floor(min+(max-min)*rel)
				fill.Size=UDim2.new(rel,0,1,0)
				valLbl.Text=tostring(val)
				if callback then callback(val) end
			end
		end)
		return f
	end

	function api:Dropdown(text,options,callback)
		local open=false
		local f=Instance.new("Frame")
		f.Size=UDim2.new(1,0,0,32)
		f.BackgroundColor3=Color3.fromRGB(34,34,40)
		f.ClipsDescendants=true
		f.Parent=page
		corner(f,6)

		local lbl=Instance.new("TextLabel")
		lbl.Size=UDim2.new(1,-20,0,32)
		lbl.Position=UDim2.new(0,10,0,0)
		lbl.BackgroundTransparency=1
		lbl.Text=text
		lbl.TextColor3=Color3.fromRGB(230,230,235)
		lbl.Font=Enum.Font.Gotham
		lbl.TextSize=13
		lbl.TextXAlignment=Enum.TextXAlignment.Left
		lbl.Parent=f

		local click=Instance.new("TextButton")
		click.Size=UDim2.new(1,0,0,32)
		click.BackgroundTransparency=1
		click.Text=""
		click.Parent=f

		local list=Instance.new("UIListLayout")
		list.Padding=UDim.new(0,2)
		list.Parent=f

		local holder=Instance.new("Frame")
		holder.Size=UDim2.new(1,0,0,0)
		holder.Position=UDim2.new(0,0,0,32)
		holder.BackgroundTransparency=1
		holder.AutomaticSize=Enum.AutomaticSize.Y
		holder.Parent=f

		local holderList=Instance.new("UIListLayout")
		holderList.Padding=UDim.new(0,2)
		holderList.Parent=holder

		for _,opt in ipairs(options) do
			local ob=Instance.new("TextButton")
			ob.Size=UDim2.new(1,-10,0,26)
			ob.Position=UDim2.new(0,5,0,0)
			ob.BackgroundColor3=Color3.fromRGB(44,44,52)
			ob.Text=opt
			ob.TextColor3=Color3.fromRGB(220,220,225)
			ob.Font=Enum.Font.Gotham
			ob.TextSize=12
			ob.AutoButtonColor=false
			ob.Parent=holder
			corner(ob,5)
			ob.MouseButton1Click:Connect(function()
				lbl.Text=text..": "..opt
				open=false
				tw(f,{Size=UDim2.new(1,0,0,32)},0.15)
				if callback then callback(opt) end
			end)
		end

		click.MouseButton1Click:Connect(function()
			open=not open
			local h=open and (32+#options*28) or 32
			tw(f,{Size=UDim2.new(1,0,0,h)},0.15)
		end)
		return f
	end

	function api:ColorPicker(text,default,callback)
		local color=default or Color3.fromRGB(255,255,255)
		local f=Instance.new("Frame")
		f.Size=UDim2.new(1,0,0,32)
		f.BackgroundColor3=Color3.fromRGB(34,34,40)
		f.Parent=page
		corner(f,6)

		local lbl=Instance.new("TextLabel")
		lbl.Size=UDim2.new(1,-50,1,0)
		lbl.Position=UDim2.new(0,10,0,0)
		lbl.BackgroundTransparency=1
		lbl.Text=text
		lbl.TextColor3=Color3.fromRGB(230,230,235)
		lbl.Font=Enum.Font.Gotham
		lbl.TextSize=13
		lbl.TextXAlignment=Enum.TextXAlignment.Left
		lbl.Parent=f

		local preview=Instance.new("TextButton")
		preview.Size=UDim2.new(0,26,0,18)
		preview.Position=UDim2.new(1,-36,0.5,-9)
		preview.BackgroundColor3=color
		preview.Text=""
		preview.Parent=f
		corner(preview,4)

		local r,g,b=color.R*255,color.G*255,color.B*255
		local sliders={}
		local panel=Instance.new("Frame")
		panel.Size=UDim2.new(1,0,0,0)
		panel.Position=UDim2.new(0,0,0,32)
		panel.BackgroundTransparency=1
		panel.AutomaticSize=Enum.AutomaticSize.Y
		panel.Visible=false
		panel.Parent=f

		local pl=Instance.new("UIListLayout")
		pl.Padding=UDim.new(0,4)
		pl.Parent=panel

		local function makeChannel(name,startVal)
			local row=Instance.new("Frame")
			row.Size=UDim2.new(1,-10,0,20)
			row.Position=UDim2.new(0,5,0,0)
			row.BackgroundColor3=Color3.fromRGB(28,28,34)
			row.Parent=panel
			corner(row,4)
			local bar=Instance.new("Frame")
			bar.Size=UDim2.new(1,-10,0,4)
			bar.Position=UDim2.new(0,5,0.5,-2)
			bar.BackgroundColor3=Color3.fromRGB(50,50,58)
			bar.Parent=row
			corner(bar,2)
			local fill=Instance.new("Frame")
			fill.Size=UDim2.new(startVal/255,0,1,0)
			fill.BackgroundColor3=Color3.fromRGB(180,60,60)
			fill.Parent=bar
			corner(fill,2)
			local drag=false
			bar.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true end
			end)
			UIS.InputEnded:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
			end)
			UIS.InputChanged:Connect(function(i)
				if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
					local rel=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
					fill.Size=UDim2.new(rel,0,1,0)
					sliders[name]=rel*255
					color=Color3.fromRGB(sliders.R,sliders.G,sliders.B)
					preview.BackgroundColor3=color
					if callback then callback(color) end
				end
			end)
			sliders[name]=startVal
		end
		makeChannel("R",r)
		makeChannel("G",g)
		makeChannel("B",b)

		preview.MouseButton1Click:Connect(function()
			panel.Visible=not panel.Visible
			local h=panel.Visible and 96 or 32
			tw(f,{Size=UDim2.new(1,0,0,h)},0.15)
		end)
		return f
	end

	function api:Label(text)
		local l=Instance.new("TextLabel")
		l.Size=UDim2.new(1,0,0,24)
		l.BackgroundTransparency=1
		l.Text=text
		l.TextColor3=Color3.fromRGB(200,200,210)
		l.Font=Enum.Font.Gotham
		l.TextSize=13
		l.TextXAlignment=Enum.TextXAlignment.Left
		l.Parent=page
		return l
	end

	return api
end

return Luna
