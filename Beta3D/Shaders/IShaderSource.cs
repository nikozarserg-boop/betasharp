using BetaSharp;

namespace Beta3D.Shaders;

public interface IShaderSource
{
    string? Get(ResourceLocation location, ShaderType type);
}
