param "protobuf_version" {
  default = "3.1.0"
}

param "cpu" {
  default = "arm"
}

param "build_dir" {
  default = "{{env `HOME`}}/protobuf-build/protobuf-{{param `protobuf_version`}}"
}

param "install_dir" {
  default = "{{env `HOME`}}/protobuf-install"
}

param "archive_zip" {
  default = "protoc-{{param `protobuf_version`}}-{{platform.OS}}-{{param `cpu`}}.zip"
}

# run make check?
param "make_check" {
  default = true
}

# run make install?
param "make_install" {
  default = true
}

file.directory "proto-install" {
  destination = "{{param `install_dir`}}"
}

task "configure" {
  check       = "[[ -f Makefile ]]"
  apply       = "./configure --prefix {{param `install_dir`}}"
  dir         = "{{param `build_dir`}}/protobuf-{{param `protobuf_version`}}"
  interpreter = "/bin/bash"
  depends     = ["file.directory.proto-install"]
}

task.query "make" {
  query       = "make | tee make.out"
  dir         = "{{param `build_dir`}}"
  interpreter = "/bin/bash"
  depends     = ["task.configure"]
}

switch "make-check" {
  case "{{param `make_check`}}" "run-make-check" {
    task.query "make-check" {
      query       = "make check | tee make-check.out"
      dir         = "{{param `build_dir`}}"
      interpreter = "/bin/bash"
      depends     = ["task.query.make"]
    }
  }
}

switch "make-install" {
  case "eq {{param `make_install`}} true" "run-make-install" {
    task.query "make-install" {
      query       = "make install | tee make-install.out"
      dir         = "{{param `build_dir`}}"
      interpreter = "/bin/bash"
      depends     = ["task.query.make"]
    }

    task "create-zip" {
      check       = "[[ -f {{param `archive_zip`}} ]]"
      apply       = "zip -r {{param `archive_zip`}} bin include lib"
      dir         = "{{param `install_dir`}}"
      interpreter = "/bin/bash"
      depends     = ["task.query.make-install"]
    }
  }
}
