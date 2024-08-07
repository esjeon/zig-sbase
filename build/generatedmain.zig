const std = @import("std");
const Step = std.Build.Step;
const Builder = std.Build;
const GeneratedFile = Builder.GeneratedFile;
const LazyPath = std.Build.LazyPath;

pub const GenerateMainFileStep = struct {
    step: Step,
    builder: *Builder,

    // The name of module for which a main file will be generated.
    module_name: []const u8,

    generated: GeneratedFile,

    pub fn create(builder: *Builder, module_name: []const u8) *GenerateMainFileStep {
        const self = builder.allocator.create(GenerateMainFileStep) catch unreachable;
        self.* = GenerateMainFileStep{
            .step = Step.init(.{ .id = .run, .name = builder.fmt("Generate main for module {s}", .{module_name}), .owner = builder, .makeFn = make }),
            .builder = builder,
            .module_name = module_name,
            .generated = GeneratedFile{ .step = &self.step },
        };

        return self;
    }

    pub fn getSource(self: *GenerateMainFileStep) LazyPath {
        return LazyPath{
            .generated = .{
                .file = &self.generated,
            },
        };
    }

    fn make(step: *Step, options: Step.MakeOptions) !void {
        _ = options;

        const self = @as(*GenerateMainFileStep, @fieldParentPtr("step", step));

        const basename = self.builder.fmt("{s}_main.zig", .{self.module_name});
        const fullpath = self.builder.fmt("src/{s}", .{basename});

        var dir = try std.fs.cwd().openDir("src", .{});
        var file = try dir.createFile(basename, .{});
        defer file.close();

        try file.writeAll("const mod = @import(\"");
        try file.writeAll(self.module_name);
        try file.writeAll(".zig\");");
        try file.writeAll(
            \\
            \\pub fn main() !u8 {
            \\    return mod.modMain();
            \\}
        );

        self.generated.path = fullpath;
    }
};
