import glob
import os
import sys

from submodules.snore_core.build_utils import print_error


default_lib_name = "Scaffolder"
default_addon_dir_name = "scaffolder"


def set_up(
    env: object,
    cpp_paths: list[str],
    sources: list[str],
    scaffolder_addon_dir_name: str,
    is_setup_for_self=False,
) -> None:
    if not os.path.isdir("submodules/snore_core"):
        print_error("submodules/snore_core must be a submodule of the root repository.")
        sys.exit(1)

    src_path = (
        is_setup_for_self
        and "src/"
        or "submodules/{}/src/".format(scaffolder_addon_dir_name)
    )
    cpp_paths.extend([src_path])
    sources.extend(glob.glob("{}**/*.cpp".format(src_path), recursive=True))
