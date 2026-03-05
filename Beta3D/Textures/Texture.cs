namespace Beta3D.Textures;

public abstract class Texture(Texture.TextureUsage usage, string label, TextureFormat format, int width, int height, int depthOrLayers, int mipLevels) : IDisposable
{
    [Flags]
    public enum TextureUsage
    {
        CopyDst = 1,
        CopySrc = 2,
        TextureBinding = 4,
        RenderAttachment = 8,
        CubemapCompatible = 16
    }

    public int DepthOrLayers { get; } = depthOrLayers;
    public int MipLevels { get; } = mipLevels;
    public TextureFormat Format { get; } = format;
    public TextureUsage Usage { get; } = usage;
    public string Label { get; init; } = label;

    public abstract bool IsDisposed { get; }

    public int GetWidth(int mipLevel) => width >> mipLevel;
    public int GetHeight(int mipLevel) => height >> mipLevel;

    public abstract void Dispose();
}
