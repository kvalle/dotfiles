require "erb"
require "tempfile"

root = File.expand_path("..", __dir__)
template = ERB.new(File.read(File.join(root, "starship/starship.toml.erb")), trim_mode: "-")

variants = {
  "starship.toml" => {
    description: "Catppuccin Macchiato dark mode",
    palette_name: "catppuccin_macchiato",
    directory_surface: "teal",
    directory_foreground: "crust",
    git_surface: "maroon",
    git_branch_foreground: "crust",
    git_status_foreground: "crust",
    git_state_foreground: "mantle",
    secondary_style: "dimmed ",
    palette: <<~TOML.chomp,
      [palettes.catppuccin_macchiato]
      rosewater = "#f4dbd6"
      flamingo = "#f0c6c6"
      pink = "#f5bde6"
      mauve = "#c6a0f6"
      red = "#ed8796"
      maroon = "#ee99a0"
      peach = "#f5a97f"
      yellow = "#eed49f"
      green = "#a6da95"
      teal = "#8bd5ca"
      sky = "#91d7e3"
      sapphire = "#7dc4e4"
      blue = "#8aadf4"
      lavender = "#b7bdf8"
      text = "#cad3f5"
      subtext1 = "#b8c0e0"
      subtext0 = "#a5adcb"
      overlay2 = "#939ab7"
      overlay1 = "#8087a2"
      overlay0 = "#6e738d"
      surface2 = "#5b6078"
      surface1 = "#494d64"
      surface0 = "#363a4f"
      base = "#24273a"
      mantle = "#1e2030"
      crust = "#181926"
    TOML
  },
  "starship-light.toml" => {
    description: "Everforest Contrast light mode",
    palette_name: "everforest_contrast",
    directory_surface: "teal_surface",
    directory_foreground: "teal",
    git_surface: "maroon_surface",
    git_branch_foreground: "maroon",
    git_status_foreground: "red",
    git_state_foreground: "maroon",
    secondary_style: "",
    palette: <<~TOML.chomp,
      [palettes.everforest_contrast]
      red = "#b83f3d"
      maroon = "#c94f4c"
      peach = "#c65f18"
      yellow = "#a87700"
      green = "#657a00"
      teal = "#287f60"
      cyan = "#2c7198"
      blue = "#2c7198"
      lavender = "#aa4d8e"
      crust = "#3d4c4f"
      mantle = "#526164"
      teal_surface = "#e4e8bd"
      maroon_surface = "#f8d4ca"
    TOML
  }
}

check = ARGV == ["--check"]
abort "Usage: #{File.basename($PROGRAM_NAME)} [--check]" unless ARGV.empty? || check

stale = variants.each_with_object([]) do |(filename, values), outdated|
  output = template.result_with_hash(values)
  path = File.join(root, "starship", filename)

  if check
    outdated << filename unless File.exist?(path) && File.read(path) == output
  else
    Tempfile.create(filename, File.dirname(path)) do |file|
      file.write(output)
      file.chmod(0o644)
      file.close
      File.rename(file.path, path)
    end
  end
end

abort "Outdated generated Starship config: #{stale.join(', ')}" unless stale.empty?
