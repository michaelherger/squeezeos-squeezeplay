-------------------------------------------------------------------------------
-- Coroutine safe xpcall and pcall versions
--
-- Encapsulates the protected calls with a coroutine based loop, so errors can
-- be dealed without the usual Lua 5.0 pcall/xpcall issues with coroutines
-- yielding inside the call to pcall or xpcall.
--
-- Authors: Roberto Ierusalimschy and Andre Carregal 
-- Contributors: Thomas Harning Jr., Ignacio Burgue�o 
--
-- Copyright 2005-2007 - Kepler Project (www.keplerproject.org)
--
-- $Id: coxpcall.lua,v 1.11 2007/12/14 20:34:46 mascarenhas Exp $
-------------------------------------------------------------------------------

local oldpcall, oldxpcall, unpack = pcall, xpcall, unpack
local coroutine = require("coroutine")

module(...)

-------------------------------------------------------------------------------
-- Implements xpcall with coroutines
-------------------------------------------------------------------------------
local performResume, handleReturnValue

function handleReturnValue(err, co, status, ...)
    if not status then
        return false, err(...)
    end
    if coroutine.status(co) == 'suspended' then
        return performResume(err, co, coroutine.yield(...))
    else
        return true, ...
    end
end

function performResume(err, co, ...)
    return handleReturnValue(err, co, coroutine.resume(co, ...))
end    

function coxpcall(f, err, ...)
    local res, co = oldpcall(coroutine.create, f)
    if not res then
        local params = {...}
        local newf = function() return f(unpack(params)) end
        co = coroutine.create(newf)
    end
    return performResume(err, co, ...)
end

local function id(...)
  return ...
end

-------------------------------------------------------------------------------
-- Implements pcall with coroutines
-------------------------------------------------------------------------------
function copcall(f, ...)
    return coxpcall(f, id, ...)
end