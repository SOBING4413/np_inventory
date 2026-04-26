# np_inventory

Resource inventory base yang bisa langsung **drag-and-drop** ke folder `resources` FiveM, dengan konsep **inventory context** seperti ox_inventory (player, trunk, glovebox, stash, drop).

## Compatibility

Auto-detect framework berikut:
- QBCore (`qb-core`)
- ESX (`es_extended`)
- ox_core (`ox_core`)
- Qbox (`qbx_core`)
- Standalone fallback (license identifier)

Auto-detect database berikut:
- `oxmysql`
- `mysql-async`
- Memory fallback (jika DB belum ada)

## Inventory Context (gaya ox_inventory)

Inventory disimpan per konteks:
- `player` (milik tiap player)
- `trunk` (shared by plate/id)
- `glovebox` (shared by plate/id)
- `stash` (shared by stash name)
- `drop` (shared by drop id)

Artinya trunk/stash/glovebox tidak ketabrak data player, dan masing-masing punya slot + maxWeight sendiri.

## Instalasi Cepat

1. Copy folder resource ini ke server (`resources/[local]/np_inventory`).
2. Pastikan salah satu framework (opsional) dan salah satu DB connector berjalan.
3. Tambahkan ke `server.cfg`:

```cfg
ensure oxmysql
# atau ensure mysql-async

ensure qb-core
# atau es_extended / ox_core / qbx_core

ensure np_inventory
```

4. Restart server.
5. Test in-game:

```txt
/show-nui
/show-trunk ABC123
/show-stash police_armory
```

## Konfigurasi

File: `shared/config.lua`

- `Config.Framework = 'auto'` (atau `qbcore`, `esx`, `ox_core`, `qbox`, `standalone`)
- `Config.Database = 'auto'` (atau `oxmysql`, `mysql-async`, `memory`)
- `Config.InventoryProfiles` untuk set slot/weight per konteks (`player`, `trunk`, `glovebox`, `stash`, `drop`)

## Exports (Server)

- `exports.np_inventory:OpenInventory(source, invType, data)`
  - contoh: `OpenInventory(src, 'trunk', { plate = 'ABC123' })`
- `exports.np_inventory:GetInventory(source)` (player inventory)
- `exports.np_inventory:GetInventory(source, 'stash', 'police_armory')`
- `exports.np_inventory:SetInventory(source, inventory)` (player inventory)
- `exports.np_inventory:SetInventory(source, 'trunk', 'ABC123', inventory)`

## Catatan Stabilitas

- Tabel `np_inventory_data` dibuat otomatis saat resource start.
- Data inventory disimpan sebagai JSON agar lintas framework tetap aman.
- Jika framework atau DB tidak ditemukan, sistem fallback ke memory tanpa crash.
