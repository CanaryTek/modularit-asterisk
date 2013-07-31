Cookbook: modularit-asterisk
==========================

A Chef cookbook to install and configure asterisk servers

This cookbook downloads and builds asterisk from sources

Right now this cookbook is just a **quick and dirty** proof of concept companion for the modularit-kamailio cookbook:

https://github.com/CanaryTek/modularit-kamailio

Requirements
------------

A base CentOS 6 server

Attributes
----------

Not much yet. Read the file...

Usage
-----

Once you have your server running, if you wan't to manage your configs by yourself insted of using Chef, you can set the following attribute in the server's chef node:

    node['asterisk']['voicemail']['manage_configs']=false

Contributing
------------

  1. Fork the repository on Github
  2. Create a named feature branch (like `add_component_x`)
  3. Write you change
  4. Write tests for your change (if applicable)
  5. Run the tests, ensuring they all pass
  6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Kuko Armas <kuko@canarytek.com>
