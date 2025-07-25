#!/usr/bin/env python
import sys
import zipfile

from submodules.snore_core.build_utils import (
    add_submodule_to_zip,
    create_submodule_addons_symlinks,
    default_addon_dir_name as snore_core_addon_dir_name,
    post_setup as post_setup_snore_core,
    pre_setup as pre_setup_snore_core,
    set_up as set_up_snore_core,
)
from build_utils import (
    default_addon_dir_name as scaffolder_addon_dir_name,
    default_lib_name as scaffolder_lib_name,
    set_up as set_up_scaffolder,
)


env = pre_setup_snore_core(ARGUMENTS, Environment, Variables, Help, SConscript)

if env["is_zipping"]:
    # Skip the normal build process, and just zip the current build.
    with zipfile.ZipFile(
        "build/{}.zip".format(scaffolder_lib_name), "w", zipfile.ZIP_DEFLATED
    ) as zf:
        add_submodule_to_zip(zf, snore_core_addon_dir_name, False)
        add_submodule_to_zip(zf, scaffolder_addon_dir_name, True)
    sys.exit(0)

cpp_paths = []
sources = []

set_up_snore_core(
    env,
    cpp_paths,
    sources,
    snore_core_addon_dir_name,
    is_setup_for_self=False,
)
set_up_scaffolder(
    env,
    cpp_paths,
    sources,
    scaffolder_addon_dir_name,
    is_setup_for_self=True,
)

post_setup_snore_core(
    env,
    cpp_paths,
    sources,
    scaffolder_lib_name,
    scaffolder_addon_dir_name,
    Default,
)

create_submodule_addons_symlinks(snore_core_addon_dir_name, False)
create_submodule_addons_symlinks(scaffolder_addon_dir_name, True)
