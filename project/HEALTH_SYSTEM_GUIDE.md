# Health System Testing Guide

## Features Implemented:

### Player Health System:
- **Max Health**: 100 HP
- **Starting Health**: 100 HP
- **Invincibility Frames**: 0.5 seconds after taking damage
- **Visual Feedback**: Red tint when taking damage
- **Death Handling**: Scene reloads on death

### Enemy Damage:
- **Enemy Attack Damage**: 10 HP per hit
- **Attack Cooldown**: 1 second between hits
- **Collision Detection**: Enemies damage player on contact

### HUD Display:
- **Health Bar**: Visual progress bar (red on dark gray)
- **Health Text**: Shows "HP: current/max"
- **Real-time Updates**: Automatically updates when health changes

## Testing the System:

1. **Start the game** and check that the HUD shows "HP: 100/100"
2. **Get hit by an enemy** - you should:
   - See the health bar decrease
   - See the HP text update (e.g., "HP: 90/100")
   - Notice a red tint flash on the player sprite
   - Be invincible for 0.5 seconds (enemy can't damage you again immediately)
3. **Take multiple hits** until health reaches 0
   - Player should fade out
   - Scene should reload

## Debug Commands (optional):

You can add these to player.gd for testing:

```gdscript
func _input(event):
	if event.is_action_pressed("ui_page_up"):  # Page Up key
		heal(10)  # Heal 10 HP
	if event.is_action_pressed("ui_page_down"):  # Page Down key
		take_damage(10)  # Take 10 damage
```

## Customization Options:

In `player.gd`:
- `max_health` - Change max HP (default: 100)
- `invincibility_duration` - Change i-frames duration (default: 0.5s)
- `attack_damage` - Player's damage to enemies (default: 10)

In `enemy.gd`:
- `attack_damage` - Enemy damage to player (default: 10)
- `attack_cooldown` - Time between attacks (default: 1.0s)
- `health_amount` - Enemy health (default: 50)

## Color Customization:

Edit `player_health.tscn` StyleBoxFlat resources:
- Background: Currently dark gray (0.3, 0.3, 0.3)
- Fill (health bar): Currently red (0.8, 0.2, 0.2)
