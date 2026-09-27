"""Module YamlParser"""

from collections.abc import Mapping
from typing import Any, cast

import strictyaml  # pyright: ignore[reportMissingTypeStubs]
from loguru import logger


class YamlParserError(Exception):
    """Custom class for yaml parsing error"""


class YamlParser:
    """Class YamlParser"""

    def __init__(self) -> None:
        self.data: dict[str, Any] = {}

    def parse(self, path: str) -> None:
        logger.debug("Parse YAML file [{}]", path)

        # Read file content into string
        try:
            with open(path, "r", encoding="utf-8") as yaml_file:
                yaml_text = yaml_file.read()
        except OSError as err:
            logger.error("Error opening the file [{}]", path)
            raise YamlParserError from err
        # Validate YAML and parse it into a dict
        try:
            strict_yaml = cast(Any, strictyaml)
            load_yaml = strict_yaml.load
            yaml_data = load_yaml(yaml_text).data
        except strictyaml.YAMLError as err:
            logger.error("Error parsing the YAML [{}]", path)
            raise YamlParserError from err
        if isinstance(yaml_data, Mapping):
            self.data.update(cast(Mapping[str, Any], yaml_data))
