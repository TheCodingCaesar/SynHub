wifi.setmode(wifi.STATION);
wifi.sta.config("The MasterMind","abcd1234")
wifi.sta.connect()
print("Connecting to Wifi..")
dofile("MqttClient.lua")
