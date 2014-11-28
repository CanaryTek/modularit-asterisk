# Author:: Kuko Armas
# Cookbook Name:: modularit-asterisk
# Attribute:: sounds

# Generic sounds
default['asterisk']['server']['sounds_url'] = "http://downloads.asterisk.org/pub/telephony/sounds/"
# Langs to download. Sorry, no extra-sounds-es :(
default['asterisk']['server']['sounds_langs'] = %w{en es}
default['asterisk']['server']['sounds_formats'] = %w{g729 gsm wav}

# Additional spanish sounds
default['asterisk']['server']['sounds_es_url'] = "http://www.voipnovatos.es/voces/"
default['asterisk']['server']['sounds_es_formats'] = %w{g729 gsm ulaw alaw}

