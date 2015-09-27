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

local LrPrefs = import 'LrPrefs'
local LrView = import 'LrView'

local RampInfoProvider = {}

function RampInfoProvider.sectionsForBottomOfDialog(viewFactory, propertyTable )
  local f = io.open(_PLUGIN:resourceId("LICENSE"), "r")
  local license = f:read("*a")
  f:close()
  return 
  {
    {
      title = LOC "$$$/Ramp/License/Title=License",
      viewFactory:row 
      {
        viewFactory:static_text { title = license }
      }
    }
  }
end

return RampInfoProvider