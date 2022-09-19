-- Resource Metadata
fx_version 'cerulean'
games {'gta5'}
author 'ZickZackHD <ZickZackHD#4834>, SeaLife'
description "lp_sperrzone is an simple all in one Skript to manage resticet zones"
version "1.0.0"
name "lp_sperrzone"
url 'https://github.com/zickzackhd'
lua54 'yes'

shared_script {
	'config.lua'
}

client_script {
    "@es_extended/locale.lua",
	"client/main.lua"
}

server_script {
    "@es_extended/locale.lua",
    "server/main.lua"
}

dependencies {
	'es_extended'
}

