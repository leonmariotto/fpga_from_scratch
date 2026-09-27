"""LogicLab command-line interface."""

import os
from dataclasses import dataclass
from pathlib import Path

import click

from logic_lab.programmer import Programmer
from logic_lab.project import LogicLabProject
from logic_lab.simulator import Simulator
from logic_lab.synthetizer import Synthetizer


@dataclass(frozen=True)
class CliContext:
    """Values shared by LogicLab subcommands."""

    project_path: Path
    oss_cad_path: Path


def get_environment() -> Path:
    """Return the configured OSS CAD Suite path or terminate the CLI."""

    oss_cad_path = os.environ.get("OSS_CAD_PATH")
    if not oss_cad_path:
        raise click.ClickException("OSS_CAD_PATH environment variable is not set")
    return Path(oss_cad_path).expanduser().resolve()


@click.group()
@click.option(
    "-p",
    "--project-path",
    type=click.Path(exists=True, file_okay=False, path_type=Path),
    default=".",
    show_default="current directory",
    help="Project directory containing logiclab.yml.",
)
@click.pass_context
def logic_lab(context: click.Context, project_path: Path) -> None:
    """Orchestrate simulation and synthesis for a digital-design project."""

    oss_cad_path = get_environment()
    context.obj = CliContext(project_path.resolve(), oss_cad_path)


def _get_project(context: click.Context) -> LogicLabProject:
    cli_context = context.obj
    if not isinstance(cli_context, CliContext):
        raise click.ClickException("LogicLab command context is unavailable")
    return LogicLabProject(
        cli_context.project_path,
        Synthetizer(cli_context.oss_cad_path),
        Simulator(cli_context.oss_cad_path),
        Programmer(cli_context.oss_cad_path),
    )


@logic_lab.command()
@click.pass_context
def show(context: click.Context) -> None:
    """Show all configured synthesis and simulation targets."""

    _get_project(context).show_off()


@logic_lab.command()
@click.option(
    "-t",
    "--target",
    "targets",
    multiple=True,
    help="Synthesis target to run; repeat to select multiple targets.",
)
@click.pass_context
def synth(context: click.Context, targets: tuple[str, ...]) -> None:
    """Run all or selected synthesis targets."""

    _get_project(context).run_synth(list(targets))


@logic_lab.command()
@click.option(
    "-t",
    "--target",
    "targets",
    multiple=True,
    help="Simulation target to run; repeat to select multiple targets.",
)
@click.pass_context
def sim(context: click.Context, targets: tuple[str, ...]) -> None:
    """Run all or selected simulation targets."""

    _get_project(context).run_sim(list(targets))


@logic_lab.command()
@click.option(
    "-t",
    "--target",
    help="Synthesis target whose bitstream should be programmed.",
)
@click.pass_context
def program(context: click.Context, target: str | None) -> None:
    """Program a synthesized bitstream using openFPGALoader."""

    _get_project(context).run_program(target)
