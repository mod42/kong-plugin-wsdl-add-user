-- If you're not sure your plugin is executing, uncomment the line below and restart Kong
-- then it will throw an error which indicates the plugin is being loaded at least.

--assert(ngx.get_phase() == "timer", "The world is coming to an end!")

---------------------------------------------------------------------------------------------
-- In the code below, just remove the opening brackets; `[[` to enable a specific handler
--
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
---------------------------------------------------------------------------------------------



local plugin = {
  PRIORITY = 1000, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}



-- do initialization here, any module level code runs in the 'init_by_lua_block',
-- before worker processes are forked. So anything you add here will run once,
-- but be available in all workers.



-- handles more initialization, but AFTER the worker process has been forked/created.
-- It runs in the 'init_worker_by_lua_block'
function plugin:init_worker()

  -- your custom code here
  kong.log.debug("saying hi from the 'init_worker' handler")

end --]]



--[[ runs in the 'ssl_certificate_by_lua_block'
-- IMPORTANT: during the `certificate` phase neither `route`, `service`, nor `consumer`
-- will have been identified, hence this handler will only be executed if the plugin is
-- configured as a global plugin!
function plugin:certificate(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'certificate' handler")

end --]]



--[[ runs in the 'rewrite_by_lua_block'
-- IMPORTANT: during the `rewrite` phase neither `route`, `service`, nor `consumer`
-- will have been identified, hence this handler will only be executed if the plugin is
-- configured as a global plugin!
function plugin:rewrite(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'rewrite' handler")

end --]]



-- runs in the 'access_by_lua_block'
function plugin:access(plugin_conf)

  -- your custom code here
  kong.log.inspect(plugin_conf)   -- check the logs for a pretty-printed config!
  
  local xmlua = require("xmlua")
  
  local body = kong.request.get_raw_body()
  if body == nil then
      kong.log("Abbruch")
      return
  end

  -- Parses XML
    if body then
      kong.log.info("body found")        
      local soapMessage = xmlua.XML.parse(body)
      -- Find <soap:Body> element using the xpath expression
      local soap_header_element, err = soapMessage:css_select("Header")[1]
      if soap_header_element then
        soap_header_element:unlink()
      end 
      local function strfmt(t)
        return string.format('%04d-%02d-%02dT%02d:%02d:%02dZ', 
            t.year,  t.month,  t.day, 
            t.hour or 0,  t.min or 0,  t.sec or 0)
      end
      local now_table = os.date('*t')
      local now_string = strfmt(now_table)

      local envelope = soapMessage:root()
      envelope:insert_element(1, 	'<soap:header>\
      <wsse:Security soap:mustUnderstand="1"\
                        xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"\
                        xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">\
             <wsse:UsernameToken>\
                 <wsse:Username>'.. plugin_conf.username ..'</wsse:Username>\
                 <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">\
                 '.. plugin_conf.password ..'\
                 </wsse:Password>\
                 <wsse:Nonce\
                         EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">\
                         somenonce\
                 </wsse:Nonce>\
                 <wsu:Created>'.. now_string .. '</wsu:Created>\
             </wsse:UsernameToken>\
         </wsse:Security>\
    </soap:header>')
   kong.service.request.set_raw_body(soapMessage:to_xml())
    end
      
    

end --]]


-- runs in the 'header_filter_by_lua_block'
function plugin:header_filter(plugin_conf)

  -- your custom code here, for example;
  -- kong.response.set_header(plugin_conf.response_header, "this is on the response")

end --]]


-- runs in the 'body_filter_by_lua_block'
function plugin:body_filter(plugin_conf)
 
  
  kong.log.debug("saying hi from the 'body_filter' handler")

end



--[[ runs in the 'log_by_lua_block'
function plugin:log(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'log' handler")

end --]]


-- return our plugin object
return plugin
