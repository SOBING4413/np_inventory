# np_inventory

Resource inventory base yang bisa langsung **drag-and-drop** ke folder `resources` FiveM.

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
5. Test in-game dengan command:

```txt
/show-nui
```

## Konfigurasi

File: `shared/config.lua`

- `Config.Framework = 'auto'` (atau `qbcore`, `esx`, `ox_core`, `qbox`, `standalone`)
- `Config.Database = 'auto'` (atau `oxmysql`, `mysql-async`, `memory`)
- `Config.DefaultSlots`
- `Config.DefaultMaxWeight`

## Catatan Stabilitas

- Tabel `np_inventory_players` dibuat otomatis saat resource start.
- Data inventory disimpan sebagai JSON agar lintas framework tetap aman.
- Jika framework atau DB tidak ditemukan, sistem fallback tanpa crash.

## Exports (Server)

- `exports.np_inventory:GetInventory(source[, cb])`
- `exports.np_inventory:SetInventory(source, inventory)`
