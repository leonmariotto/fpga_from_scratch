from pathlib import Path

from logic_lab.yaml_parser import YamlParser


def test_parse_yaml_file(tmp_path: Path) -> None:
    config = tmp_path / "logiclab.yaml"
    config.write_text(
        """\
project: single_cycle
sources:
  - single_cycle.sv
top: single_cycle
""",
        encoding="utf-8",
    )

    parser = YamlParser()
    parser.parse(str(config))

    assert parser.data == {
        "project": "single_cycle",
        "sources": ["single_cycle.sv"],
        "top": "single_cycle",
    }
