#!/usr/bin/env python3
import hassapi as hass


class EqualizeBrightness(hass.Hass):
    async def initialize(self) -> None:
        """Initialize the app with a list of lights to be equalized."""
        # Get the list of lights from the configuration
        self.lights = []
        for light_name in self.args["lights"]:
            self.lights.append(self.get_entity(light_name))

        # Track current brightness settings, to avoid changing attrs multiple times.
        self.brightness = None

        for light in self.lights:
            # `duration` debounces callbacks
            light.listen_state(
                self.equalize_attribute, attribute="brightness", duration=0.1
            )

    async def equalize_attribute(
        self, entity: str, attribute: str, old, new, **_
    ) -> None:

        if new is not None and self.brightness != new:
            self.brightness = new
            attrs = {attribute: new}
            for light in self.lights:
                if light != entity:
                    self.log(
                        f"entity: {entity}, attribute: {attribute}, old: {old}, new: {new}, light: {light}"
                    )
                    light.call_service("turn_on", **attrs)
