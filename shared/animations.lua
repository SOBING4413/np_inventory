Config = Config or {}

Config.Animations = {
  consume = {
    dict = 'mp_player_inteat@burger',
    clip = 'mp_player_int_eat_burger',
    duration = 2200,
    flags = 49,
  },
  drink = {
    dict = 'mp_player_intdrink',
    clip = 'loop_bottle',
    duration = 2000,
    flags = 49,
  },
}

Config.ItemAnimations = {
  water = 'drink',
  bread = 'consume',
}
