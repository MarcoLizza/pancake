local empty, read_write = {}, { read_only = false }

local function def_fields(...)
   local fields = {}

   for _, field in ipairs({...}) do
      fields[field] = empty
   end

   return {fields = fields}
end

local love = {
   fields = {
      getVersion = empty,
      setDeprecationOutput = empty,
      hasDeprecationOutput = empty,
      conf = read_write,
      directorydropped = read_write,
      draw = read_write,
      errorhandler = read_write,
      filedropped = read_write,
      focus = read_write,
      gamepadaxis = read_write,
      gamepadpressed = read_write,
      gamepadreleased = read_write,
      joystickadded = read_write,
      joystickaxis = read_write,
      joystickhat = read_write,
      joystickpressed = read_write,
      joystickreleased = read_write,
      joystickremoved = read_write,
      keypressed = read_write,
      keyreleased = read_write,
      load = read_write,
      lowmemory = read_write,
      mousefocus = read_write,
      mousemoved = read_write,
      mousepressed = read_write,
      mousereleased = read_write,
      quit = read_write,
      resize = read_write,
      run = read_write,
      textedited = read_write,
      textinput = read_write,
      threaderror = read_write,
      touchmoved = read_write,
      touchpressed = read_write,
      touchreleased = read_write,
      update = read_write,
      visible = read_write,
      wheelmoved = read_write,

      audio = def_fields("getActiveSourceCount","getDistanceModel","getDopplerScale",
         "getSourceCount","getOrientation","getPosition","getVelocity","getVolume","newSource",
         "pause","play","resume","rewind","setDistanceModel","setDopplerScale","setOrientation",
         "setPosition","setVelocity","setVolume","stop"),

      event = def_fields("clear","poll","pump","push","quit","wait"),

      filesystem = def_fields("append","areSymlinksEnabled","createDirectory","getAppdataDirectory",
         "getCRequirePath","getDirectoryItems","getIdentity","getInfo","getRealDirectory",
         "getRequirePath","getSaveDirectory","getSource","getSourceBaseDirectory",
         "getUserDirectory","getWorkingDirectory","init","isFused","lines","load","mount","newFile",
         "newFileData","read","remove","setCRequirePath","setIdentity","setRequirePath","setSource",
         "setSymlinksEnabled","unmount","write"),

      graphics = def_fields("arc","applyTransform","captureScreenshot","circle","clear","discard",
         "draw","drawInstanced","drawLayer","ellipse","flushBatch","getBackgroundColor",
         "getBlendMode","getCanvas","getCanvasFormats","getColor","getColorMask",
         "getCompressedImageFormats","getDefaultFilter","getDepthMode","getDimensions","getFont",
         "getFrontFaceWinding","getHeight","getLineJoin","getLineStyle","getLineWidth",
         "getMeshCullMode","getShader","getStackDepth","getStats","getStencilTest","getSupported",
         "getSystemLimits","getPointSize","getRendererInfo","getScissor","getTextureTypes",
         "getWidth","intersectScissor","inverseTransformPoint","isGammaCorrect","isWireframe",
         "line","newCanvas","newFont","newMesh","newImage","newImageFont","newParticleSystem",
         "newShader","newText","newQuad","newSpriteBatch","newVideo","origin","points","polygon",
         "pop","present","print","printf","push","rectangle","replaceTransform","reset","rotate",
         "scale","setBackgroundColor","setBlendMode","setCanvas","setColor","setColorMask",
         "setDefaultFilter","setDepthMode","setFont","setFrontFaceWinding","setLineJoin",
         "setLineStyle","setLineWidth","setMeshCullMode","setNewFont","setShader","setPointSize",
         "setScissor","setStencilTest","setWireframe","shear","stencil","transformPoint",
         "translate","validateShader"),

      image = def_fields("isCompressed","newCompressedData","newImageData"),

      joystick = def_fields("getJoystickCount","getJoysticks","loadGamepadMappings",
         "saveGamepadMappings","setGamepadMapping"),

      keyboard = def_fields("getKeyFromScancode","getScancodeFromKey","hasKeyRepeat","hasTextInput",
         "isDown","isScancodeDown","setKeyRepeat","setTextInput"),

      math = def_fields("compress","decompress","gammaToLinear","getRandomSeed","getRandomState",
         "isConvex","linearToGamma","newBezierCurve","newRandomGenerator","newTransform","noise",
         "random","randomNormal","setRandomSeed","setRandomState","triangulate"),

      mouse = def_fields("getCursor","getPosition","getRelativeMode","getSystemCursor","getX",
         "getY","hasCursor","isCursorSupported","isDown","isGrabbed","isVisible","newCursor",
         "setCursor","setGrabbed","setPosition","setRelativeMode","setVisible","setX","setY"),

      physics = def_fields("getDistance","getMeter","newBody","newChainShape","newCircleShape",
         "newDistanceJoint","newEdgeShape","newFixture","newFrictionJoint","newGearJoint",
         "newMotorJoint","newMouseJoint","newPolygonShape","newPrismaticJoint","newPulleyJoint",
         "newRectangleShape","newRevoluteJoint","newRopeJoint","newWeldJoint","newWheelJoint",
         "newWorld","setMeter"),

      sound = def_fields("newDecoder","newSoundData"),

      system = def_fields("getClipboardText","getOS","getPowerInfo","getProcessorCount","openURL",
         "setClipboardText","vibrate"),

      thread = def_fields("getChannel","newChannel","newThread"),

      timer = def_fields("getAverageDelta","getDelta","getFPS","getTime","sleep","step"),

      touch = def_fields("getPosition","getPressure","getTouches"),

      video = def_fields("newVideoStream"),

      window = def_fields("close","fromPixels","getDisplayName","getDPIScale","getFullscreen",
         "getFullscreenModes","getIcon","getMode","getPixelScale","getPosition","getTitle",
         "hasFocus","hasMouseFocus","isDisplaySleepEnabled","isMaximized","isMinimized","isOpen",
         "isVisible","maximize","minimize","restore","requestAttention","setDisplaySleepEnabled",
         "setFullscreen","setIcon","setMode","setPosition","setTitle","showMessageBox","toPixels",
         "updateMode")
   }
}

return {
   read_globals = { love = love }
}