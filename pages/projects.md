---
layout: default
professional:
- [
    "Opam Repo CI",
    "https://github.com/benmandrew/opam-repo-ci",
    "OCaml, Docker",
    "CI for testing submissions to the Opam Repository, the central package universe for the OCaml ecosystem"
  ]
- [
    "OCaml CI",
    "https://github.com/benmandrew/ocaml-ci",
    "OCaml, Docker",
    "CI for testing OCaml projects on a wide range of operating systems, architectures, and OCaml versions"
  ]
- [
    "Multicoretests CI",
    "https://github.com/benmandrew/multicoretests-ci",
    "OCaml, Docker",
    "CI for stress-testing the newly introduced OCaml 5 compiler, which exposed several bugs in the multicore runtime"
  ]
- [
    "OCaml on a microcontroller",
    "/articles/porting-ocaml-to-nrf52",
    "C, ARM assembly",
    "Running OCaml bytecode on an ARM microcontroller, on top of the RIOT real-time OS"
  ]

theorem_proving:
- [
    "Cavalry",
    "/articles/cavalry",
    "OCaml",
    "Mini-language where programs can be verified for correctness using a Hoare logic-style approach"
  ]
- [
    "PCTL",
    "/articles/pctl",
    "OCaml",
    "Model checker for verifying safety properties using Probabilistic Computation Tree Logic"
  ]
- [
    "Saguaro",
    "https://github.com/benmandrew/saguaro",
    "OCaml",
    "Propositional logic SAT solver using the DPLL method"
  ]

systems:
- [
    "DTLSR",
    "/articles/dtlsr-project",
    "C, Unix",
    "Undergraduate thesis project implementing Delay-Tolerant Link-State Routing, tested on the CORE network emulator"
  ]
- [
    "BF",
    "https://github.com/benmandrew/bf",
    "C, LLVM",
    "Brainf*ck compiler frontend targeting the LLVM Intermediate Representation (IR)"
  ]
- [
    "TTT86",
    "/articles/tic-tac-toe-x86-assembly",
    "x86 Assembly",
    "Tic-Tac-Toe in x86 assembly, using direct syscalls"
  ]

graphics:
- [
    "Discrete Distortion",
    "/articles/discrete-distortion",
    "C++",
    "Art project demonstrating cool algorithmic image effects"
  ]
- [
    "JSTableRenderer",
    "/articles/js-table-renderer",
    "JavaScript",
    "3D renderer using a HTML table's cells as a pixel grid"
  ]
- [
    "Mirror",
    "/articles/rendering-geometric-patterns",
    "OCaml",
    "Experiments with repeating geometric patterns, inspired by \"Islamic Patterns: An Analytical and Cosmological Approach\" by Keith Critchlow"
  ]
- [
    "Sable",
    "https://github.com/benmandrew/sable",
    "Rust",
    "Multithreaded simulation of falling sand"
  ]
- [
    "Otorus",
    "https://github.com/benmandrew/Otorus",
    "OCaml",
    "Torus ray-tracer, rendering to a window or terminal"
  ]
- [
    "Lux",
    "/articles/lux-project",
    "C++, Python",
    "Triangle mesh ray-tracer, accelerated with a bounding volume hierarchy (BVH) data structure"
  ]

games:
- [
    "Goblin Heist",
    "/articles/goblin-heist",
    "Unity/C#",
    "Entry for the Ludum Dare 48 game jam"
  ]
- [
    "Trench Warfare",
    "/articles/trench-warfare",
    "Unity/C#",
    "Strategy game inspired by the flash game \"Warfare 1917\""
  ]
- [
    "Monopoly Deal",
    "/articles/curses-terminal-card-game",
    "Python, Curses",
    "Terminal implementation of the Monopoly Deal card game over the network"
  ]
- [
    "Munch",
    "https://github.com/benmandrew/munch",
    "Rust",
    "Pacman clone using the ggez game engine"
  ]
- [
    "Cosmic Taxi",
    "/articles/cosmic-taxi",
    "Unity/C#",
    "Entry for the Ludum Dare 47 game jam"
  ]
- [
    "Cryogen",
    "/articles/cryogen",
    "Unity/C#",
    "Entry for the Ludum Dare 46 game jam"
  ]
- [
    "Revenant",
    "/articles/revenant",
    "Unity/C#",
    "Largely unfinished arena-based wave survival game, inspired by Devil Daggers"
  ]
- [
    "Ändleite",
    "/articles/field-of-view-in-a-tile-based-world",
    "C++, SDL2",
    "Tech demo for field-of-view in a tile-based world"
  ]
---

# Projects

## Professional

<div class="post-list row" style="margin: auto;">
  {%- for info in page.professional -%}
  <div class="col-md-6 justify-content-center" style="margin-bottom:15px">
    <a class="card h-100" href="{{ info[1] }}">
      <div class="card-body">
        <h5 class="card-title">{{ info[0] }}</h5>
        <p class="card-subtitle text-muted">{{ info[3] }}</p>
        <p class="text-warning" style="margin-top: 10px; margin-bottom: -10px" align="right">{{ info[2] }}</p>
      </div>
    </a>
  </div>
  {%- endfor -%}
</div>

## Formal Methods

<div class="post-list row" style="margin: auto; margin-bottom:10px">
  {%- for info in page.theorem_proving -%}
  <div class="col-md-6 justify-content-center" style="margin-bottom:15px">
    <a class="card h-100" href="{{ info[1] }}">
      <div class="card-body">
        <h5 class="card-title">{{ info[0] }}</h5>
        <p class="card-subtitle text-muted">{{ info[3] }}</p>
        <p class="text-success" style="margin-top: 10px; margin-bottom: -10px" align="right">{{ info[2] }}</p>
      </div>
    </a>
  </div>
  {%- endfor -%}
</div>

## Systems

<div class="post-list row" style="margin: auto; margin-bottom:10px">
  {%- for info in page.systems -%}
  <div class="col-md-6 justify-content-center" style="margin-bottom:15px">
    <a class="card h-100" href="{{ info[1] }}">
      <div class="card-body">
        <h5 class="card-title">{{ info[0] }}</h5>
        <p class="card-subtitle text-muted">{{ info[3] }}</p>
        <p class="text-primary" style="margin-top: 10px; margin-bottom: -10px" align="right">{{ info[2] }}</p>
      </div>
    </a>
  </div>
  {%- endfor -%}
</div>

## Graphics

<div class="post-list row" style="margin: auto; margin-bottom:10px">
  {%- for info in page.graphics -%}
  <div class="col-md-6 justify-content-center" style="margin-bottom:15px">
    <a class="card h-100" href="{{ info[1] }}">
      <div class="card-body">
        <h5 class="card-title">{{ info[0] }}</h5>
        <p class="card-subtitle text-muted">{{ info[3] }}</p>
        <p class="text-danger" style="margin-top: 10px; margin-bottom: -10px" align="right">{{ info[2] }}</p>
      </div>
    </a>
  </div>
  {%- endfor -%}
</div>

## Games

<div class="post-list row" style="margin: auto; margin-bottom:10px">
  {%- for info in page.games -%}
  <div class="col-md-6 justify-content-center" style="margin-bottom:15px">
    <a class="card h-100" href="{{ info[1] }}">
      <div class="card-body">
        <h5 class="card-title">{{ info[0] }}</h5>
        <p class="card-subtitle text-muted">{{ info[3] }}</p>
        <p class="text-info" style="margin-top: 10px; margin-bottom: -10px" align="right">{{ info[2] }}</p>
      </div>
    </a>
  </div>
  {%- endfor -%}
</div>
