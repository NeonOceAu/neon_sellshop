
# Neon Sell Shop

A GTA V FiveM script that allows players to sell items through an interactive shop system with customizable framework options (QBCore/ESX) and interaction options (ox_target, qb-target, textui).

## Features

- Support for both **QBCore** and **ESX** frameworks.
- Configurable **interaction system** with options for `target` (ox_target/qb-target) and `textui`.
- Configurable **dynamic pricing** for shops.
- Supports **clean and dirty money** transactions.
- **Discord logs** for item sales.

## Installation

### 1. Clone or Download the Repository

Download or clone the repository into your FiveM resources folder:

```bash
git clone https://github.com/YourUsername/neon_sellshop.git
```

### 2. Configure `config.lua`

In the `config.lua`, configure the following:

- **Framework**: Set the framework to either 'QB' for QBCore or 'ESX' for ESX.
- **Interaction**: Choose between `target` (default) or `textui`.
- **Target**: If using `target`, set either `ox_target` (default) or `qb-target`.

Example configuration:

```lua
Config = {
    Framework = 'QB',
    Interaction = 'target',
    Target = 'ox_target',
    -- Add shop details here
}
```

### 3. Add to `server.cfg`

Ensure that the script is added to your server configuration (`server.cfg`):

```bash
ensure neon_sellshop
```

### 4. Set Up Discord Webhook

In `sv_utils.lua`, replace `'YOUR_DISCORD_WEBHOOK_URL'` with your actual Discord Webhook URL.

```lua
local webhookUrl = 'YOUR_DISCORD_WEBHOOK_URL'
```

### 5. Dependencies

Ensure you have the following dependencies installed on your server:

- `ox_lib`
- `ox_target`
- `qb-target`
- `ox_inventory`
- `qb-core` or `es_extended`

## Usage

- Configure your shops in `config.lua`.
- Start your server and interact with the ped at the configured shop locations.
- Players can sell items from their inventory and receive either clean or dirty money.

## Contributing

Feel free to submit issues or pull requests to contribute to the development of this script.

## License

This project is licensed under the MIT License.
