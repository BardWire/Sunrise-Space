/*
	Sunrise - A new era
	Do not edit or change unless with premission of the sunrise dev's
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local Vect = Vector(0,0,5)

ENT.Weap = "Citizen_Laser"
ENT.Damage = 1000
ENT.NumShots = 1 -- Howmany times we need to shoot.
ENT.ShotDelay = 0.5 -- Delay between shots when we fire multiple shots.
ENT.NextFireDelay = 1 -- The delay between shots.

ENT.NextFire = 0
ENT.IgnoreWarpCollide = true

function ENT:Initialize()
	self:SetModel("models/thesunrise/laserturret.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Sleep()
	end
end

function ENT:Think()
	if !self.Deployer then
		self.Deployer = "Global"
	end
	if !self.Target or !self.Target:IsValid() or self.Target:GetPos():Distance(self:GetPos()) >= 500 then
		self.Target = nil
		self:FindTarget()
		return
	end
	if self.Target:GetPos():Distance(self:GetPos()) < 500 and self.NextFire <= CurTime() then
		self:Shoot(self.Target)
	end

	self:NextThink(CurTime()+0.1)
end

function ENT:GetHP()
	return self.aHealth or 0
end


function ENT:FindTarget()
	local ply = player.GetAll()
	local PlayerIsHostile = ply:GetNWInt("Hostile")
	for _,v in pairs(ents.FindInSphere(self:GetPos(),500)) do
		if v.IsPirate or PlayerIsHostile or GAMEMODE:GetRelation(self.Deployer,v) <= -1 then
			self.Target = v
			break
		end
	end
end

function ENT:SetWeapon(wep)
	self.Weap = tostring(wep)
end

function ENT:GetWeapon()
	return self.Weap
end

function ENT:KeyValue(k,v)
	if k == "Weapon" then
		self.Weap = v
	end
end

function ENT:Shoot(ent)
	local func = CW_GetFunction(self.Weap)
	if ent and ent:IsValid() and self.NextFire <= CurTime() and type(func) == "function" then
		local td = {}
		td.start = self:GetPos()
		td.endpos = ent:GetPos()
		td.filter = {self}
		local t = util.TraceLine(td)
		for i=1,self.NumShots do
			timer.Simple(i*self.ShotDelay,func,t,self,self.Damage,ent)
		end
		self.NextFire = CurTime()+(self.NextFireDelay+(self.NumShots/2))
	end
end

function ENT:TakeDMG(a,b)
	//Disable DMG
	return
end

function ENT:Die()
	local ed = EffectData()
	ed:SetOrigin(self:GetPos())
	ed:SetMagnitude(5)
	util.Effect("sunrise_turretdeath",ed)
	self:Remove()
end
