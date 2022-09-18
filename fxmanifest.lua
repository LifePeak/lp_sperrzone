-- 
-- Truck Deliveries by SeaLife
--

name "Sperrzone"

description "Sperrzone auf der Karte"

author "SeaLife"

version "1.0.0-SNAPSHOT"

url "https://r3ktm8.de"

client_script {
	"config.lua",
	"client/main.lua"
}

server_script {
    "config.lua",
    "server/main.lua"
}

fx_version 'cerulean'

lua54 'yes'

game "gta5"