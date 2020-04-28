--[[ OBS Studio datetime script

This script transforms up to two text sources into a digital clock. The datetime format
is configurable and uses the same syntax than the Lua os.date() call.

Modified to accept a second source to allow splitting the date and time.
]]

obs             = obslua

DateTimeSource = {
	source_name     = "",
	datetime_format = "",
	activated       = false
}

function DateTimeSource:new (o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function DateTimeSource:activate(activating)
	if self.activated == activating then
		return
	end

	self.activated = activating
	
	if activating then
		obs.timer_add(self.timer_callback, 1000)
	else
		obs.timer_remove(self.timer_callback)
	end
end

function DateTimeSource:reset()
	self:activate(false)
	local source = obs.obs_get_source_by_name(self.source_name)
	if source ~= nil then
		local active = obs.obs_source_showing(source)
		obs.obs_source_release(source)
		self:activate(active)
	end
end

-- Function to set the time text
function set_datetime_text(source, format)
	local text = os.date(format)
	local settings = obs.obs_data_create()

	obs.obs_data_set_string(settings, "text", text)
	obs.obs_source_update(source, settings)
	obs.obs_data_release(settings)
end

source1 = DateTimeSource:new()
source1.timer_callback = function() 
	local source = obs.obs_get_source_by_name(source1.source_name)
	if source ~= nil then
		set_datetime_text(source, source1.datetime_format)
		obs.obs_source_release(source)
	end
end

source2 = DateTimeSource:new()
source2.timer_callback = function()
	local source = obs.obs_get_source_by_name(source2.source_name)
	if source ~= nil then
		set_datetime_text(source, source2.datetime_format)
		obs.obs_source_release(source)
	end
end

-- Called when a source is activated/deactivated
function activate_signal(cd, activating)
	local source = obs.calldata_source(cd, "source")
	if source ~= nil then
		local name = obs.obs_source_get_name(source)
		if (name == source1.source_name) then
			source1:activate(activating)
		end
		if (name == source2.source_name) then
			source2:activate(activating)
		end
	end
end

function source_activated(cd)
	activate_signal(cd, true)
end

function source_deactivated(cd)
	activate_signal(cd, false)
end

----------------------------------------------------------

function script_description()
	return "Sets a text source to act as a clock when the source is active.\
Optional secondary source to allow having date and time in different places.\
\
The datetime format can use the following tags:\
\
    %a	abbreviated weekday name (e.g., Wed)\
    %A	full weekday name (e.g., Wednesday)\
    %b	abbreviated month name (e.g., Sep)\
    %B	full month name (e.g., September)\
    %c	date and time (e.g., 09/16/98 23:48:10)\
    %d	day of the month (16) [01-31]\
    %H	hour, using a 24-hour clock (23) [00-23]\
    %I	hour, using a 12-hour clock (11) [01-12]\
    %M	minute (48) [00-59]\
    %m	month (09) [01-12]\
    %p	either \"am\" or \"pm\" (pm)\
    %S	second (10) [00-61]\
    %w	weekday (3) [0-6 = Sunday-Saturday]\
    %x	date (e.g., 09/16/98)\
    %X	time (e.g., 23:48:10)\
    %Y	full year (1998)\
    %y	two-digit year (98) [00-99]\
    %z	Timezone Abbrev (e.g. EDT)\
    %Z	Timezone full (e.g. Eastern Daylight Time)\
    %%	the character `%´\
    %n	new line"
end

function script_properties()
	local props = obs.obs_properties_create()

	obs.obs_properties_add_text(props, "format", "Datetime format", obs.OBS_TEXT_DEFAULT)
	local p = obs.obs_properties_add_list(props, "source", "Text Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)

	obs.obs_properties_add_text(props, "format2", "Datetime format (Secondary)", obs.OBS_TEXT_DEFAULT)
	local p2 = obs.obs_properties_add_list(props, "source2", "Text Source (Secondary)", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)

	local sources = obs.obs_enum_sources()
	local text_sources = {text_gdiplus_v2 = true, text_gdiplus = true, text_ft2_source = true}
	if sources ~= nil then
		for _, source in ipairs(sources) do
			source_id = obs.obs_source_get_id(source)
			if text_sources[source_id] then
				local name = obs.obs_source_get_name(source)
				obs.obs_property_list_add_string(p, name, name)
				obs.obs_property_list_add_string(p2, name, name)
			end
		end
	end
	obs.source_list_release(sources)

	return props
end

function script_defaults(settings)
	obs.obs_data_set_default_string(settings, "format", "%X")
end

function script_update(settings)
	source1:activate(false)
	source2:activate(false)

	source1.source_name = obs.obs_data_get_string(settings, "source")
	source1.datetime_format = obs.obs_data_get_string(settings, "format")
	source2.source_name = obs.obs_data_get_string(settings, "source2")
	source2.datetime_format = obs.obs_data_get_string(settings, "format2")

	source1:reset()
	source2:reset()
end

function script_load(settings)
	local sh = obs.obs_get_signal_handler()
	obs.signal_handler_connect(sh, "source_show", source_activated)
	obs.signal_handler_connect(sh, "source_hide", source_deactivated)
end
