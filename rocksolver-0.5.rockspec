-- This file was automatically generated for the LuaDist project.

package = "rocksolver"
version = "0.5"
-- LuaDist source
source = {
  url = "git://github.com/LuaDist-core/rocksolver.git",
  tag = "0.5"
}
-- Original source
-- source = {
--     tag = "0.4.2",
--     url = "git://github.com/smasty/rocksolver.git"
-- }
description = {
    summary = "Dependency resolver library for LuaDist packages.",
    homepage = "http://github.com/smasty/rocksolver",
    license = "MIT"
}
dependencies = {
    "lua >= 5.1",
    "md5 >= 1.2-1",
}
build = {
    type = "builtin",
    modules = {
        ["rocksolver.DependencySolver"] = "rocksolver/DependencySolver.lua",
        ["rocksolver.Package"] = "rocksolver/Package.lua",
        ["rocksolver.constraints"] = "rocksolver/constraints.lua",
        ["rocksolver.utils"] = "rocksolver/utils.lua",
    }
}
