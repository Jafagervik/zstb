#  ZSTB - Zig Standard Library Extension

## Requirements

* Zig Version 0.14.0

## Usage 

To install, run: 

```sh
zig fetch --save git+https://github.com/Jafagervik/zstb#{version}
```

Where {version} is the release version you want to use; e.g 0.1.7: 

```sh
zig fetch --save git+https://github.com/Jafagervik/zstb#v0.1.7
```

In your `build.zig` file: add like this:

```zig 
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zstb_dep = b.dependency("zstb", .{});
    const zstb = zstb_dep.module("zstb");

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("path/to/your/main/source/file"),
        .target = target,
        .optimize = optimize,
    });

    exe_mod.addImport("zstb", zstb);
```

Then, to use it, include it in a file like such: 

```zig 
const zstb = @import("zstb");

const a = "a";
const b = "b";

const isSame = zstb.strings.eql("a", "b");
std.debug.print("{any}\n", .{isSame});
```

See `examples/` for example setup

## Modules

### Strings

* join
* concat 
* isEmpty
* isNullOrEmpty
* eql -- shortcut for std.mem.eql(u8, a, b)
* isNumeric

Now for char operations

* isWhitespace
* isAlpha
* isDigit -- base 10

### Types 

* str = `[]const u8`
