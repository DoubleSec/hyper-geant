### Hyper Geant

------

This project is written for the virtual machine pico-8, for my own entertainment.

It uses Flask to support daily courses (not really necessary) and leaderboards.

To build for web: `pico8 -export flaskr/static/hypergeant.js p8/hypergeant.p8`

The web implementation uses the (incredibly useful) PICO-8 GPIO listener library from here: https://github.com/benwiley4000/pico8-gpio-listener


#### Running the game on a server

**PLEASE NOTE: I am not *remotely* an expert at setting up servers, especially securely. I don't really know if this is at all the right way to do this, so please don't copy this pattern for anything important.**

Much of the code here is dedicated to running this game on a website, because it's fun. In order to do so, we need a few things:

 - We'll use nginx as a server. In `setup/nginx.conf` you can find an example configuration for nginx.
 - We're using gunicorn to run our flask app. We'll package it as a linux service: see `setup/hg.service`.

To set everything up on a fresh server, we'd want to copy the `nginx.conf` file to wherever nginx is going to look for it (typically `/etc/nginx/nginx.conf`), then we'd want to start nginx, then we'd finally want to start our gunicorn server. I'm not going to worry about placing the nginx.conf at the moment, but for the other parts, we'll use setup/hg.service to do both of them. This involves writing a shell script, `setup/hg_setup.sh`. Then `hg.service` goes in `/etc/systemd/system`.

Once everything is in place we can start the service at startup with `sudo systemctl enable hg` and start it with `sudo systemctl start hg`.
