#!/usr/bin/env python3
import asyncio
import hassapi as hass
from typing import List


class EqualizeBrightness(hass.Hass):
    async def initialize(self) -> None:
        """Initialize the app with a list of lights to be equalized."""
        # Get the list of lights from the configuration
        group_lights = self.args["lights"]

        if not group_lights:
            return

        for light in group_lights:
            self.states.register_listener(
                f"light.{light}",
                "brightness",
                lambda *args: self.listener_brightness(
                    self, args[0], args[1], group_lights
                ),
            )

        async def listener_brightness(
            self, event_type: str, data: dict, group_lights: List[str]
        ) -> None:
            """Listen for brightness changes on any light and adjust other lights in the group."""
            await asyncio.sleep(0.1)
            triggered_light = next(
                entity for entity in group_lights if entity == data["entity_id"]
            )
            current_brightness = hass.states.get(triggered_light)["attributes"][
                "brightness"
            ]

            # Update all other lights in the group
            for light in group_lights:
                if light != data["entity_id"]:
                    await self.set_light_brightness(light, current_brightness)

    async def set_light_brightness(
        self, target_light: str, brightness_value: int
    ) -> None:
        """Set the brightness of a light."""
        await hass.services.async_call(
            "light",
            "set_brightnes",
            {"entity_id": target_light, "brightness": brightness_value},
        )
