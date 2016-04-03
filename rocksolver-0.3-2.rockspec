-- This file was automatically generated for the LuaDist project.

package = "RockSolver"
version = "0.3-2"
-- LuaDist source
source = {
  tag = "0.3-2",
  url = "git://github.com/LuaDist2/rocksolver.git"
}
-- Original source
-- source = {
--     tag = "v0.3",
--     url = "git://github.com/smasty/rocksolver.git"
-- }
description = {
    summary = "Dependency resolver library for LuaDist packages.",
    homepage = "http://github.com/smasty/rocksolver",
    license = "MIT"
}
dependencies = {
    "lua >= 5.1"
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