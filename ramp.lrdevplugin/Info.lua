--[[--------------------------------------------------------------
 Copyright (C) 2015 David Milligan

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the
Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor,
Boston, MA  02110-1301, USA. 
----------------------------------------------------------------]]

return 
{	
	LrSdkVersion = 6.0,
	LrSdkMinimumVersion = 6.0,
	LrToolkitIdentifier = 'org.ml.ramp',
	LrPluginName = LOC "$$$/Ramp/PluginName=LrRamp",
	LrPluginInfoUrl = "https://github.com/davidmilligan/LrRamp",
	LrExportMenuItems = 
	{
		title = "Ramp",
		file = "Ramp.lua",
	},
	--LrInitPlugin = 'RampInit.lua',
	LrPluginInfoProvider = "RampInfoProvider.lua",
	VERSION = { major=1, minor=0, revision=0, build=0, },
}


	
