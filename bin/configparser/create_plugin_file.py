from log import *

TEMPLATE_PATH="./templates/plugin_template_minimal.nix"
PLUGIN_BASE_PATH="../../src/plugins/"
#  PLUGIN_TEST_BASE_PATH="./plugins/utils/"

def remove_trailing_whitespace(file):
    with open(file, 'r') as infile:
        # Read the content of the file and remove trailing whitespace
        lines = [line.rstrip() for line in infile]

    with open(file, 'w') as outfile:
        # Write the modified content back to the file
        outfile.write('\n'.join(lines))

def add_whitespace(input_string, num_spaces):
    return '\n'.join([' ' * num_spaces + line for line in input_string.split('\n')])

class PluginFile:
    """
    Creates a copy of the plugin template and fills in all information
    """

    def __init__(self,
                 name: str,
                 url: str,
                 options: str):

        info(f"Writing plugin file for {name}")

        if name == "" or url == "":
            raise ValueError("name url and plugin_name have to be set")


        module_name = name.lower()
        if name.endswith("-nvim"):
            module_name = name[:-5]


        plugin_path = PLUGIN_BASE_PATH + module_name.lower() + ".nix"

        options = add_whitespace(options[3:-2], 2)
        #  name = f"(lib.warn \"{module_name} module is autogenerated. Please report any bugs\" {name})"

        self.module_name = module_name
        self.options = options
        self.plugin_path = plugin_path
        self.url = url
        self.name = name

    def write(self):
        with open(TEMPLATE_PATH, "r") as f:
            content = f.read()
            debug(f"module_name: {self.module_name}")
            # NOTE: dont change any of the spaces in the replace string
            content = content.replace("PLUGIN_NAME", self.module_name)
            content = content.replace("PLUGIN_URL", self.url)
            content = content.replace("  # add module options here", self.options[1:-2])

            content = content.replace("# add neovim plugin here", self.name)
            print()
            print(content[270:-920])
            print()

            debug(f"Writing file: {self.plugin_path}")
            try:
                with open(self.plugin_path, "x") as new_file:
                    new_file.write(content)

                remove_trailing_whitespace(self.plugin_path)
            except FileExistsError:
                warning("Plugin already exists. Skipping ...")


        # TODO: copy file test

        #  info("Adding new files to git")
        #  subprocess.run(["git", "add", plugin_path])
        #  print("Files added to git.")
