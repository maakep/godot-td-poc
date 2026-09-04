# Status effects

Gameplay and presentation are intentionally separate:

- `StatusEffectDefinition` describes identity, stacking, gameplay capabilities,
  resistance, and the reusable visual channel.
- `StatusEffectApplication` contains the values delivered by a tower or ability.
- `StatusEffectRuntime` contains per-enemy duration, source, and stack state.
- `StatusEffectComponent` owns active runtimes and updates only while non-empty.
- `StatusEffectView` maps active runtimes to one shared procedural overlay.

## Adding an effect

1. Create a definition in `definitions/` and choose an explicit stack policy.
2. Reuse one of the four visual channels. Multiple effects in the same channel
   are combined with a saturating intensity curve.
3. Create an application in `applications/` with duration, magnitude, tick
   interval, and damage values.
4. Put the application resource in a projectile's `effects` array.

Give definitions semantic `tags` to opt into central reactions. Current recipes
are fire + oil, fire + poison, and impact + frost. Reaction outcomes are applied
directly so they cannot recursively trigger themselves.

Movement reduction and periodic damage need no new code. For unusual gameplay,
subclass `StatusEffectBehavior` and assign the behavior to the definition.
Behavior resources must remain stateless; per-target state belongs on the runtime.

## Performance constraints

- Do not add a particle node per runtime. The overlay renders all current motifs
  in one CanvasItem and is hidden when no visual effect is active.
- Do not mutate shared definitions or applications at runtime.
- Visual parameters are updated only when effects are applied, refreshed, or
  removed. Animation happens in the shader.
- The component advances at 20 Hz and is disabled while empty.
