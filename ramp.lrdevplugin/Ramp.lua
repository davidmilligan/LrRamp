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

local LrApplication = import 'LrApplication'
local LrApplicationView = import 'LrApplicationView'
local LrDevelopController = import 'LrDevelopController'
local LrDialogs = import 'LrDialogs'
local LrErrors = import 'LrErrors'
local LrFunctionContext = import 'LrFunctionContext'
local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local LrPrefs = import 'LrPrefs'
local LrProgressScope = import 'LrProgressScope'
local LrTasks = import 'LrTasks'

--[[--------------------------------------------------------------
Lr Develop Settings (from SDK)
----------------------------------------------------------------]]
local developSettings = {
  adjustPanel = {
   "Temperature",
   "Tint",
   "Exposure",
   "Highlights",
   "Shadows",
   "Brightness",
   "Contrast",
   "Whites",
   "Blacks",
   "Clarity",
   "Vibrance",
   "Saturation",
  },
  tonePanel = {
   "ParametricDarks",
   "ParametricLights",
   "ParametricShadows",
   "ParametricHighlights",
   "ParametricShadowSplit",
   "ParametricMidtoneSplit",
   "ParametricHighlightSplit",
  },
  mixerPanel = {
   -- HSL / Color
   "SaturationAdjustmentRed",
   "SaturationAdjustmentOrange",
   "SaturationAdjustmentYellow",
   "SaturationAdjustmentGreen",
   "SaturationAdjustmentAqua",
   "SaturationAdjustmentBlue",
   "SaturationAdjustmentPurple",
   "SaturationAdjustmentMagenta",
   "HueAdjustmentRed",
   "HueAdjustmentOrange",
   "HueAdjustmentYellow",
   "HueAdjustmentGreen",
   "HueAdjustmentAqua",
   "HueAdjustmentBlue",
   "HueAdjustmentPurple",
   "HueAdjustmentMagenta",
   "LuminanceAdjustmentRed",
   "LuminanceAdjustmentOrange",
   "LuminanceAdjustmentYellow",
   "LuminanceAdjustmentGreen",
   "LuminanceAdjustmentAqua",
   "LuminanceAdjustmentBlue",
   "LuminanceAdjustmentPurple",
   "LuminanceAdjustmentMagenta",
   -- B & W
   "GrayMixerRed",
   "GrayMixerOrange",
   "GrayMixerYellow",
   "GrayMixerGreen",
   "GrayMixerAqua",
   "GrayMixerBlue",
   "GrayMixerPurple",
   "GrayMixerMagenta",
  },
  splitToningPanel = {
   "SplitToningShadowHue",
   "SplitToningShadowSaturation",
   "SplitToningHighlightHue",
   "SplitToningHighlightSaturation",
   "SplitToningBalance",
  },
  detailPanel = {
   "Sharpness",
   "SharpenRadius",
   "SharpenDetail",
   "SharpenEdgeMasking",
   "LuminanceSmoothing",
   "LuminanceNoiseReductionDetail",
   "LuminanceNoiseReductionContrast",
   "ColorNoiseReduction",
   "ColorNoiseReductionDetail",
   "ColorNoiseReductionSmoothness",
  },
  effectsPanel = {
   -- Dehaze
   "Dehaze",
   -- Post-Crop Vignetting
   "PostCropVignetteAmount",
   "PostCropVignetteMidpoint",
   "PostCropVignetteFeather",
   "PostCropVignetteRoundness",
   "PostCropVignetteStyle",
   "PostCropVignetteHighlightContrast",
   -- Grain
   "GrainAmount",
   "GrainSize",
   "GrainFrequency",
  },
  lensCorrectionsPanel = {
   -- Profile
   "LensProfileDistortionScale",
   "LensProfileChromaticAberrationScale",
   "LensProfileVignettingScale",
   "LensManualDistortionAmount",
   -- Color
   "DefringePurpleAmount",
   "DefringePurpleHueLo",
   "DefringePurpleHueHi",
   "DefringeGreenAmount",
   "DefringeGreenHueLo",
   "DefringeGreenHueHi",
   -- Manual Perspective
   "PerspectiveVertical",
   "PerspectiveHorizontal",
   "PerspectiveRotate",
   "PerspectiveScale",
   "PerspectiveAspect",
   "PerspectiveUpright",
  },
  calibratePanel = {
   "ShadowTint",
   "RedHue",
   "RedSaturation",
   "GreenHue",
   "GreenSaturation",
   "BlueHue",
   "BlueSaturation",
  }
}

local log = LrLogger('exportLogger')
log:enable("print")

--replace the default assert behavior to use LrErrors.throwUserError
local assertOriginal = assert
local function assert(condition, message)
  if condition ~= true then
    if message == nil then 
      assertOriginal(condition)
    else
      LrErrors.throwUserError(message)
    end
  end
end

--local prefs = LrPrefs.prefsForPlugin(_PLUGIN.id)

local function rampRange(range, catalog, progress, startIndex, totalCount)
  local count = #range
  local startValues = {}
  catalog:setSelectedPhotos(range[1],{})
  LrTasks.sleep(0.1)
  for i,panel in pairs(developSettings) do
    for j,setting in pairs(panel) do
      startValues[setting] = LrDevelopController.getValue(setting)
    end
  end
  local endValues = {}
  catalog:setSelectedPhotos(range[count],{})
  LrTasks.sleep(0.1)
  for i,panel in pairs(developSettings) do
    for j,setting in pairs(panel) do
      endValues[setting] = LrDevelopController.getValue(setting)
    end
  end
  progress:setPortionComplete(startIndex, totalCount)
  
  for i,photo in ipairs(range) do
    if i ~= 1 and i ~= count then
      local lastComputed = -1
      local currentFilename = photo:getFormattedMetadata("fileName")
      catalog:setSelectedPhotos(photo,{})
      log:trace(currentFilename)
      for j,panel in pairs(developSettings) do
        for k,setting in pairs(panel) do
          local startValue = startValues[setting]
          local endValue = endValues[setting]
          if type(startValue) == "number" and type(endValue) == "number" then
            local target = startValue + (endValue - startValue) * (i / count)
            LrDevelopController.setValue(setting,target)
            log:trace(" "..setting..": "..tostring(target))
          end
        end
      end
      if progress:isCanceled() then LrErrors.throwCanceled() end
    end
    progress:setPortionComplete(startIndex + i, totalCount)
  end
end

local function ramp(context)
  log:trace("ramp started")
  LrDialogs.attachErrorDialogToFunctionContext(context)
  local catalog = LrApplication.activeCatalog();
  local selection = catalog:getTargetPhotos();
  local count = #selection
  assert(count > 2, "Not enough photos selected")
  
  local progress = LrProgressScope { title="Ramp", functionContext = context }
  
  LrApplicationView.switchToModule("develop")
  
  local range = {}
  local lastStartIndex = 1
  
  for i,photo in ipairs(selection) do
    if i == count or photo:getRawMetadata("rating") == 1 then
      range[#range + 1] = photo
      rampRange(range, catalog, progress, lastStartIndex, count)
      lastStartIndex = i
      range = {}
    end
    range[#range + 1] = photo
  end
  
  --restore selection
  catalog:setSelectedPhotos(selection[1],selection)
  progress:done()
  log:trace("ramp finished")
end

LrFunctionContext.postAsyncTaskWithContext("ramp", ramp)


