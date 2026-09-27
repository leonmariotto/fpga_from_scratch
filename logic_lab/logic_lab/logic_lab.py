"""LogicLab command-line interface."""

from pathlib import Path

import click


@click.command()
@click.option(
    "--project-path",
    type=click.Path(exists=True, file_okay=False, path_type=Path),
    required=True,
    help="Project directory containing logiclab.yaml.",
)
def logic_lab(project_path: Path) -> None:
    """Orchestrate simulation and synthesis for a digital-design project."""

    click.echo(f"Project: {project_path}")
