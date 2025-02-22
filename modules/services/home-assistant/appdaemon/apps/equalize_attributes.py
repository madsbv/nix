#!/usr/bin/env python3
import hassapi as hass


class EqualizeAttributes(hass.Hass):
    async def initialize(self) -> None:
        """Initialize the app with lists of entities and attributes to be equalized."""
        # Get the list of entities from the configuration
        self.entities = []
        for name in self.args["lights"]:
            self.entities.append(self.get_entity(name))

        # List of attributes to monitor and equalize
        self.attributes = self.args["attributes"]
        self.log(self.attributes)

        self.excludes = {}
        # "mutually_exclusive": List of lists of strings.
        # For each list, if the first element is the name of an attribute that's supposed to be set to a non-null value, the attributes named by the remaining entries will be removed from the call to the `turn_on` service. This happens on a per-entity basis.
        # E.g.: For Tapo bulbs, if the color_temp_kelvin is set (i.e. in white light mode), you cannot also send hs_color (corresponding to color mode), or you get a 400 response and the light does not update.
        # This makes some sense since such a request could be seen as ambiguous regarding whether the light should be in white or color mode, but unfortunately the state of a light in white mode includes both color_temp and color as non-null values, so we can't just copy-paste state from one light to the next.
        if self.args.get("excludes") is not None:
            for criterion in self.args.get("excludes"):
                if len(criterion) >= 2:
                    self.excludes[criterion[0]] = criterion[1:]
        self.log(self.excludes)

        # Track current attribute values, to avoid changing attrs multiple times.
        self.current = {}

        for entity in self.entities:
            # `duration` debounces callbacks
            entity.listen_state(self.equalize_attributes, attribute="all", duration=0.1)

    # Current assumptions: There's a `state` attribute with values `on`/`off`, and services `turn_on` and `turn_off`, where `turn_on` takes **kwargs of attributes to set.
    # `turn_off` may support attributes, but we do not support using them.
    # Only valid attributes for an entity are accessed and updated.
    # If the `state` attribute is set to be equalized, entities will be turned on and off together, otherwise only attributes of entities that are already on will be updated.
    async def equalize_attributes(
        self, entity: str, _attribute: str, _old, new, **_
    ) -> None:
        if (
            "state" in self.attributes
            and new.get("state") == "off"
            and self.current.get("state") != "off"
        ):
            self.current["state"] = "off"
            for e in self.entities:
                if e != entity and e.get_state("state") != "off":
                    self.log(f"Entity {entity} turned off, turning entity {e} off.")
                    e.call_service("turn_off")
            return

        if new.get("state") == "on":
            new_attrs = new.get("attributes")
            update_attrs = {}
            excluded = set()
            for attr, value in {
                key: new_attrs[key] for key in self.attributes & new_attrs.keys()
            }.items():
                if self.current.get(attr) != value and value is not None:
                    self.current[attr] = value
                    update_attrs[attr] = value

            if update_attrs != {}:
                self.log(f"new_attrs: {new_attrs}")
                self.log(f"update_attrs: {update_attrs}")
                for e in self.entities:
                    if e != entity:
                        e_state = await e.get_state("all")
                        e_attrs = e_state.get("attributes")
                        self.log(f"e_state for {e}: {e_state}")
                        e_new_keys = update_attrs.keys() & e_attrs.keys()
                        e_new_attrs = {key: e_attrs[key] for key in e_new_keys}
                        change_attrs = {
                            key: update_attrs[key]
                            for key in e_new_keys.difference(excluded)
                        }
                        # Copy necessary to not modify the dict being looped over
                        change_attrs_sanitized = dict(change_attrs)
                        for attr, value in change_attrs.items():
                            # Exclusion has to happen on a per-entity basis. E.g. if a light supporting color is updated, a light that does not support color might get the wrong change set otherwise, or vice-versa
                            if value is not None and attr in self.excludes:
                                for exclude_attr in self.excludes[attr]:
                                    if exclude_attr in change_attrs_sanitized:
                                        self.log(
                                            f"Removing attribute {exclude_attr} from change_attrs for {e} because {attr} excludes it."
                                        )
                                        del change_attrs_sanitized[exclude_attr]
                        if "state" in self.attributes or e_state.get("state") == "on":
                            self.log(
                                f"Entity {entity} triggered change, updating entity {e}: From {e_new_attrs} to {change_attrs_sanitized}"
                            )
                            self.log(
                                await e.call_service(
                                    "turn_on",
                                    return_result=True,
                                    **change_attrs_sanitized,
                                )
                            )
