"""LogicLab command-line interface."""

import os
from pathlib import Path

import click


def get_environment() -> Path:
    """Return the configured OSS CAD Suite path or terminate the CLI."""

    oss_cad_path = os.environ.get("OSS_CAD_PATH")
    if not oss_cad_path:
        raise click.ClickException("OSS_CAD_PATH environment variable is not set")
    return Path(oss_cad_path).expanduser().resolve()


@click.command()
@click.option(
    "-p",
    "--project-path",
    type=click.Path(exists=True, file_okay=False, path_type=Path),
    default=".",
    show_default="current directory",
    help="Project directory containing logiclab.yaml.",
)
def logic_lab(project_path: Path) -> None:
    """Orchestrate simulation and synthesis for a digital-design project."""

    get_environment()
    click.echo(f"Project: {project_path}")
