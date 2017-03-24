-- LuaDist Rocksolver utility functions
-- Part of the LuaDist project - http://luadist.org
-- Author: Martin Srank, hello@smasty.net
-- License: MIT

module("rocksolver.utils", package.seeall)
local const = require("rocksolver.constraints")
local md5 = require "md5"


-- Given list of Packages and a repo path template string,
-- generates a table in LuaDist manifest format.
-- repo_path should contain a %s placeholder for the package name.
-- Local manifest example:  packages/%s
-- Remote manifest example: git://github.com/LuaDist/%s.git
function generate_manifest(packages, repo_path)
    assert(type(packages) == "table", "utils.generate_manifest: Argument 'packages' is not a table.")
    assert(type(repo_path) == "string", "utils.generate_manifest: Argument 'repo_path' is not a string.")

    local Package = Package or require "rocksolver.Package"

    local modules = {}
    for _, pkg in pairs(packages) do
        assert(getmetatable(pkg) == Package, "utils.generate_manifest: Argument 'packages' does not contain Package instances.")
        if not modules[pkg.name] then
            modules[pkg.name] = {}
        end
        modules[pkg.name][pkg.version.string] = {
            dependencies = pkg.spec.dependencies,
            supported_platforms = pkg.spec.supported_platforms
        }
    end

    return {
        repo_path = repo_path,
        packages = modules
    }
end


-- Given a LuaDist manifest table, returns a list of Packages in the manifest.
-- Option argument is_local denotes a local manifest, therefore generated Packages
-- will be local as well, otherwise they will be remote.
function load_manifest(manifest, is_local)
    assert(type(manifest) == "table", "utils.load_manifest: Argument 'manifest' is not a table.")

    local Package = Package or require "rocksolver.Package"

    if not manifest.packages then return {} end
    local pkgs = {}
    for pkg_name, versions in pairs(manifest.packages) do
        for version, spec in pairs(versions) do
            table.insert(pkgs, Package(pkg_name, version, spec, is_local))
        end
    end

    return pkgs
end

-- Generates md5 hash for of binary package. Hashed string contains platform,which it was built on,names and binary compatible versions
-- (major and minor) of installed dependencies of package. E.g. if package xy has dependencies 'lua' and 'luasocket',
-- and they are installed in versions 'lua 5.2.4-1' and luasocket '3.0rc1-2' on unix platform, hashed string will
-- look like this: 'unix lua 5.2 luasocket 3.0 '
function generate_dep_hash(platform, pkg_dependencies, installed)
    local dep_hash = platform[1] .. " "
    local package_names = generate_bin_dependencies(pkg_dependencies, installed)

    for _, pkg_name in pairs(package_names) do
        dep_hash = dep_hash .. pkg_name .. " "
    end

    -- print(dep_hash)
    dep_hash = md5.sumhexa(dep_hash)
    dep_hash = dep_hash:sub(1,10)
    return dep_hash
end

function generate_bin_dependencies(pkg_dependencies, installed)
    local package_names = {}

    if not pkg_dependencies then
        return {}
    end

    for _, dependency in pairs(pkg_dependencies) do
        local found = false
        for _, installed_pkg in pairs(installed) do
            if installed_pkg:matches(dependency) and not found then
                local major, minor = const.parse_major_minor_version(installed_pkg.version)
                local parsed_package_const = installed_pkg.name .. " " .. major .. "." .. minor
                table.insert(package_names, parsed_package_const)
                found = true
            end
        end
        if not found then
          err = "Binary dependencies are not correct, probably incorrect rockspec file or manifest record."
          return dependency, err
        end
    end

    table.sort(package_names)

    return package_names, err
end

-- Returns a set-like table.
function makeset(tbl)
    local set = {}
    for _, v in pairs(tbl) do
        set[v] = true
    end
    return set
end

-- Returns an array of all the keys.
function keys(tbl)
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end


-- Creates a deep copy of a table, preserving reference to the original metatable.
-- Source: http://lua-users.org/wiki/CopyTable
function deepcopy(object)
    local lookup_table = {}
    local function copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for k, v in pairs(object) do
            new_table[copy(k)] = copy(v)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return copy(object)
end


-- Returns an iterator to a table sorted by it's keys.
-- Optional comparison function can be given as a second argument.
function sort(tbl, fn)
    local keys = {}
    for k in pairs(tbl) do keys[#keys + 1] = k end
    table.sort(keys, fn)
    local i = 0
    return function()
        i = i + 1
        return keys[i], tbl[keys[i]]
    end
end


-- helper function for debug purposes
function table_tostring(tbl, label)
    assert(type(tbl) == "table", "utils.table_tostring: Argument 'tbl' is not a table.")
    local str = ""
    for k,v in pairs(tbl) do
        if type(v) == "table" then
            if v.__tostring then
                str = str .. tostring(v) .. " "
            else
                str = str .. "(" ..table_tostring(v, k) .. ")"
            end
        else
            if label ~= nil then
                str = str .. " " .. k .. " = " .. tostring(v) .. ", "
            else
                str = str .. tostring(v) .. ", "
            end
        end
    end
    return str
end
