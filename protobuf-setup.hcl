param "build_dir" {
  default = "{{env `HOME`}}/protobuf-build"
}

param "install_dir" {
  default = "{{env `HOME`}}/protobuf-install"
}

param "protobuf_version" {
  default = "3.1.0"
}

param "packages" {
  default = "autoconf automake libtool curl make g++ unzip zip"
}

task "package-deps" {
  check = "dpkg -s {{param `packages`}} >/dev/null 2>&1"
  apply = "apt-get update 2>&1 > /dev/null && apt-get -y install {{param `packages`}}"
}

file.directory "proto-build" {
  destination = "{{param `build_dir`}}"
}

task "protobuf-src-dl" {
  check       = "[[ -f v{{param `protobuf_version`}}.tar.gz ]]"
  apply       = "curl -L -O https://github.com/google/protobuf/archive/v{{param `protobuf_version`}}.tar.gz"
  dir         = "{{param `build_dir`}}"
  interpreter = "/bin/bash"
  depends     = ["task.package-deps","file.directory.proto-build"]
}

task "protobuf-src-unzip" {
  check       = "[[ -d protobuf-{{param `protobuf_version`}} ]]"
  apply       = "tar zxvf v{{param `protobuf_version`}}.tar.gz"
  dir         = "{{param `build_dir`}}"
  interpreter = "/bin/bash"
  depends     = ["task.protobuf-src-dl"]
}

task "autogen.sh" {
  check       = "[[ -f configure ]]"
  apply       = "./autogen.sh"
  dir         = "{{param `build_dir`}}/protobuf-{{param `protobuf_version`}}"
  interpreter = "/bin/bash"
  depends     = ["task.protobuf-src-unzip"]
}
