# JR Speed Limiter

A simple FiveM ESX resource to manage vehicle speed limits with a whitelist. 
This script allows admins and specific jobs to view whitelisted vehicles and their maximum speeds via a simple menu.

---

## Features

- Show all whitelisted vehicles with their maximum speeds. /whitelistlist
- Add vehicles to whitelist. /addwhitelist
- Remove vehicles from whitelist. /removewhitelist
- Restrict access based on **admin groups** or specific **jobs**.
- Notifications for when added or removed from whitelist.
- Uses `ox_lib` for context menus and notifications.
- Easy to configure via `config.lua`.

---

## Requirements

- [ESX Framework](https://esx-framework.org/)
- [ox_lib](https://overextended.github.io/ox_lib/)

---

## Installation

1. Place this resource in your `resources` folder.
2. configure the `config.lua` to your preference  
2. Add it to your `server.cfg`:

```cfg
ensure JR_SpeedLimiter
