namespace Beta3D;

public enum TextureFormat
{
    Rgba8,
    Red8,
    Red8I,
    Depth32
}

public static class TextureFormatExtensions
{
    public static int PixelSize(this TextureFormat format) => format switch
    {
        TextureFormat.Rgba8 => 4,
        TextureFormat.Red8 => 1,
        TextureFormat.Red8I => 1,
        TextureFormat.Depth32 => 4,
        _ => throw new ArgumentOutOfRangeException(nameof(format))
    };

    public static bool HasColorAspect(this TextureFormat format) =>
        format is TextureFormat.Rgba8 or TextureFormat.Red8;

    public static bool HasDepthAspect(this TextureFormat format) =>
        format is TextureFormat.Depth32;
}
