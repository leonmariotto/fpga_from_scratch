# LogicLab

Makefile is not good here, we don't do incremental build in SystemVerilog, a 
scripting langage will be better for orchestrating synthesis/simulation.

It must be project independent, each project should give (in a top level yaml) 
metadata needed for synthesis and simulation. The buildsystem tools must only 
have the path to project and can run things directly.

Let's choose python.

Let's call it **LogicLab**, sounds good.

LogicLab must use some environment var :
- `OSS_CAD_PATH`: top level of oss cad, will be used to find binary.

A `--project_path` should always be passed to LogicLab tools, allowing tool 
to parse the top level `logiclab.yml`.

The `logiclab.yml` file at the top of the project dir must specify:
- a `synth_targets` list with, for each target: a name, a non-empty list of
source files, the top module, and a CST file;
- a `sim_targets` list with, for each target: a name and a non-empty list of
source files.

For example:

```yaml
synth_targets:
  - name: single_cycle
    sources:
      - single_cycle.sv
    top: single_cycle
    cst: dummy.cst

sim_targets:
  - name: tb_extend
    sources:
      - single_cycle.sv
      - tests/tb_extend.sv
```

LogicLab tool must provide a command to know which synth and sim target are 
available for a given project path. The tool must allow running all synthesis 
and all simulations target, but also singles.

For now synthesis and simulation option are hardcoded, but it could be great to 
have it parametrizable.
