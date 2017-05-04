print ("Mqttfile opened")
mqttOnline = false
mqttSubSuccess = false
gpio.mode(1, gpio.OUTPUT)
gpio.mode(2, gpio.OUTPUT)
gpio.write(1, gpio.LOW)
gpio.write(2, gpio.LOW)
status = false

-- timer vars
mainTimerId = 0 -- we have seven timers! 0..6
mainInterval = 1000 -- milliseconds
statusTimerID = 1
statusInterval = 10000
hackTimerID = 2
hackTimerInterval = 2000
-- client ID, keepalive (seconds), user, password
m = mqtt.Client("ESP8266_devdddddsjfsdkf", 30)


m:lwt("ab/ac/toApp", "3001", 0, 0)

m:on("connect", function(con)
   print("connected")
   mqttOnline = true
   gpio.write(2, gpio.HIGH)
   -- 0Fan            01
   m:publish("ab/ac/toApp", "0001BedRoom Light  000", 0, 0)
   -- hack to prevent stdio bomb calling subscribe in this callback
   tmr.alarm(hackTimerID, hackTimerInterval, 0, function()
      m:subscribe("ab/ac/fromApp",0, function(con)
         print("subscribe success")
         mqttSubSuccess = true
        end)
    end)
end)

m:on("offline", function(con)
   print("offline")
   mqttOnline = false
   mqttSubSuccess = false
   gpio.write(2, gpio.LOW)
end)

m:on("message", function(con, topic, msg)
   print(topic..":"..msg)
   if tostring(msg):sub(-1)=="0" then
      gpio.write(1, gpio.LOW)
      status = false
   elseif tostring(msg):sub(-1)=="1" then
      gpio.write(1, gpio.HIGH)
      status = true
   elseif tostring(msg) == "GetList" then
      setList()
   end
end)



function setList()
   tmr.delay(3000000)
   if status then
      m:publish("ab/ac/toApp", "0001BedRoom Light  001", 0, 0)
   else
      m:publish("ab/ac/toApp", "0001BedRoom Light  000", 0, 0)
   end
end


function updateMQTT()
   if wifi.sta.status() == 5 then
      if mqttOnline then
         print("Connected ")
      else
         print("calling m:connect()")
         m:connect("iot.eclipse.org", 1883)
      end
   end
end




tmr.alarm(mainTimerId, mainInterval, 1, function()
   -- counter updates whether online or not
   updateMQTT()
end)

-- print status of wifi and online every 10 sec --
tmr.alarm(statusTimerID, statusInterval, 1, function()
   print("wifi status:"..wifi.sta.status()..", MQTT Online:"..tostring(mqttOnline))
end)

