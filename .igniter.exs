# This is a configuration file for igniter.
# For option documentation, see https://hexdocs.pm/igniter/Igniter.Project.IgniterConfig.html
# To keep it up to date, use `mix igniter.setup`
# For some reason Igniter feels the need to overwrite file paths that we assign (why even accept a file path if you're just going to make one up?) so we have updated `dont_move_files`
[
  module_location: :outside_matching_folder,
  extensions: [],
  source_folders: ["lib", "test/support"],
  dont_move_files: [~r"."]
]
