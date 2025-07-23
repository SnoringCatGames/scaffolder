#!/usr/bin/env python
import os
import sys

from snore_core.build_utils import \
    post_setup as post_setup_snore_core, \
    pre_setup as pre_setup_snore_core, \
    set_up as set_up_snore_core
from build_utils import set_up as set_up_scaffolder


lib_name = "Scaffolder"
addon_dir_name = "scaffolder"

env = pre_setup_snore_core(ARGUMENTS, Environment, Variables, Help, SConscript)

cpp_paths = []
sources = []

set_up_snore_core(env, cpp_paths, sources, addon_dir_name, is_setup_for_self=False)
set_up_scaffolder(env, cpp_paths, sources, addon_dir_name, is_setup_for_self=True)

post_setup_snore_core(env, cpp_paths, sources, lib_name, addon_dir_name, Default)

# Make the SnoreCore GDExtension and GDScript addon files accessible from the Scaffolder demo.
os.symlink("snore_core/demo/addons/snore_core", "demo/addons/snore_core", target_is_directory=True)
